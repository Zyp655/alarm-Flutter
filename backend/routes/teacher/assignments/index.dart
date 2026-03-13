import 'package:backend/database/database.dart';
import 'package:backend/helpers/notification_helper.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGet(context);
    case HttpMethod.post:
      return _handlePost(context);
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _handlePost(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;
  final classId = body['classId'] as int?;
  final teacherId = body['teacherId'] as int?;
  final title = body['title'] as String?;
  final description = body['description'] as String?;
  final dueDateStr = body['dueDate'] as String?;
  final rewardPoints = body['rewardPoints'] as int? ?? 0;
  if (classId == null ||
      teacherId == null ||
      title == null ||
      dueDateStr == null) {
    return Response(
      statusCode: 400,
      body: 'Missing required fields: classId, teacherId, title, dueDate',
    );
  }
  DateTime dueDate;
  try {
    dueDate = DateTime.parse(dueDateStr);
  } catch (e) {
    return Response(statusCode: 400, body: 'Invalid dueDate format');
  }
  try {
    final assignmentId = await db.into(db.assignments).insert(
          AssignmentsCompanion.insert(
            classId: classId,
            teacherId: teacherId,
            title: title,
            description: Value(description),
            dueDate: dueDate,
            rewardPoints: Value(rewardPoints),
            createdAt: DateTime.now(),
          ),
        );
    final studentsInClass = await (db.select(db.schedules)
          ..where((s) => s.classId.equals(classId))
          ..where((s) => s.userId.isNotNull()))
        .get();
    final studentIds = studentsInClass
        .where((s) => s.userId != teacherId)
        .map((s) => s.userId)
        .toSet()
        .toList();
    for (final studentId in studentIds) {
      await db.into(db.studentAssignments).insert(
            StudentAssignmentsCompanion.insert(
              assignmentId: assignmentId,
              studentId: studentId,
            ),
          );
    }
    if (studentIds.isNotEmpty) {
      await NotificationHelper.createBatchNotifications(
        db: db,
        userIds: studentIds,
        type: 'assignment_new',
        title: 'Bài tập mới',
        message: 'Giáo viên đã giao bài tập: $title',
        relatedId: assignmentId,
        relatedType: 'assignment',
      );
    }
    return Response.json(body: {
      'message': 'Assignment created successfully',
      'assignmentId': assignmentId,
      'studentsAssigned': studentIds.length,
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'});
  }
}

Future<Response> _handleGet(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;

  final teacherId = int.tryParse(
    params['teacherId'] ?? params['userId'] ?? '',
  );
  final classId =
      params['classId'] != null ? int.tryParse(params['classId']!) : null;
  final moduleId =
      params['moduleId'] != null ? int.tryParse(params['moduleId']!) : null;

  try {
    if (moduleId != null) {
      try {
        final rows = await db.customSelect(
          'SELECT * FROM assignments WHERE module_id = $moduleId ORDER BY created_at DESC',
        ).get();

        final result = <Map<String, dynamic>>[];
        for (final row in rows) {
          final a = row.data;
          final assignmentId = a['id'] as int;
          final studentAssignments = await (db.select(db.studentAssignments)
                ..where((s) => s.assignmentId.equals(assignmentId)))
              .get();
          final pendingCount = studentAssignments.where((s) => !s.isCompleted).length;

          String? toIso(dynamic val) {
            if (val is DateTime) return val.toIso8601String();
            if (val is int) return DateTime.fromMillisecondsSinceEpoch(val * 1000).toIso8601String();
            if (val is String) return val;
            return null;
          }

          result.add({
            'id': assignmentId,
            'classId': a['class_id'],
            'teacherId': a['teacher_id'],
            'moduleId': a['module_id'],
            'title': a['title'],
            'description': a['description'],
            'dueDate': toIso(a['due_date']),
            'createdAt': toIso(a['created_at']),
            'totalStudents': studentAssignments.length,
            'pendingCount': pendingCount,
            'completedStudents': studentAssignments.length - pendingCount,
          });
        }
        return Response.json(body: {'assignments': result});
      } catch (e) {
        print('[assignments] moduleId query error: $e');
        return Response.json(body: {'assignments': [], 'error': '$e'});
      }
    }

    if (teacherId == null) {
      return Response(statusCode: 400, body: 'Missing teacherId or userId');
    }

    final query = db.select(db.assignments).join([
      leftOuterJoin(
        db.studentAssignments,
        db.studentAssignments.assignmentId.equalsExp(db.assignments.id),
      ),
    ])
      ..where(db.assignments.teacherId.equals(teacherId));
    if (classId != null) {
      query.where(db.assignments.classId.equals(classId));
    }

    final results = await query.get();
    final Map<int, Map<String, dynamic>> assignmentMap = {};
    for (final row in results) {
      final assignment = row.readTable(db.assignments);
      final studentAssignment = row.readTableOrNull(db.studentAssignments);
      if (!assignmentMap.containsKey(assignment.id)) {
        assignmentMap[assignment.id] = {
          'id': assignment.id,
          'classId': assignment.classId,
          'title': assignment.title,
          'description': assignment.description,
          'dueDate': assignment.dueDate.toIso8601String(),
          'rewardPoints': assignment.rewardPoints,
          'createdAt': assignment.createdAt.toIso8601String(),
          'totalStudents': 0,
          'completedStudents': 0,
          'pendingCount': 0,
        };
      }
      if (studentAssignment != null) {
        assignmentMap[assignment.id]!['totalStudents'] += 1;
        if (studentAssignment.isCompleted) {
          assignmentMap[assignment.id]!['completedStudents'] += 1;
        } else {
          assignmentMap[assignment.id]!['pendingCount'] += 1;
        }
      }
    }
    return Response.json(body: {'assignments': assignmentMap.values.toList()});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': '$e'});
  }
}
