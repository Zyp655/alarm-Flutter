import 'package:backend/database/database.dart';
import 'package:backend/helpers/notification_helper.dart';
import 'package:backend/services/email_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;
  final classId = body['classId'] as int?;
  final teacherId = body['teacherId'] as int?;
  final title = body['title'] as String?;
  final description = body['description'] as String?;
  final dueDateStr = body['dueDate'] as String?;
  final rewardPoints = body['rewardPoints'] as int? ?? 0;
  final moduleId = body['moduleId'] as int?;

  if (classId == null || teacherId == null || title == null || dueDateStr == null) {
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
    var resolvedClassId = classId;

    final oldClass = await (db.select(db.classes)
          ..where((c) => c.id.equals(classId)))
        .getSingleOrNull();

    if (oldClass == null) {
      final courseClasses = await (db.select(db.courseClasses)
            ..where((c) => c.academicCourseId.equals(classId)))
          .get();

      if (courseClasses.isNotEmpty) {
        final courseClass = courseClasses.first;
        var scheduleClass = await (db.select(db.classes)
              ..where((c) => c.classCode.equals(courseClass.classCode)))
            .getSingleOrNull();

        if (scheduleClass == null) {
          final course = await (db.select(db.academicCourses)
                ..where((c) => c.id.equals(classId)))
              .getSingleOrNull();
          resolvedClassId = await db.into(db.classes).insert(
                ClassesCompanion.insert(
                  className: course?.name ?? 'Lớp học',
                  classCode: courseClass.classCode,
                  teacherId: teacherId,
                  createdAt: DateTime.now(),
                ),
              );
        } else {
          resolvedClassId = scheduleClass.id;
        }
      } else {
        resolvedClassId = await db.into(db.classes).insert(
              ClassesCompanion.insert(
                className: 'Lớp ${classId}',
                classCode: 'AUTO_${classId}_${DateTime.now().millisecondsSinceEpoch}',
                teacherId: teacherId,
                createdAt: DateTime.now(),
              ),
            );
      }
    }

    final descEscaped = (description ?? '').replaceAll("'", "''");
    final titleEscaped = title.replaceAll("'", "''");
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dueDateEpoch = dueDate.millisecondsSinceEpoch ~/ 1000;
    final moduleIdSql = moduleId != null ? '$moduleId' : 'NULL';

    final result = await db.customSelect(
      "INSERT INTO assignments (class_id, teacher_id, title, description, due_date, reward_points, module_id, created_at) "
      "VALUES ($resolvedClassId, $teacherId, '$titleEscaped', '$descEscaped', $dueDateEpoch, $rewardPoints, $moduleIdSql, $nowEpoch) "
      "RETURNING id",
    ).getSingle();

    final assignmentId = result.data['id'] as int;

    final courseClasses = await (db.select(db.courseClasses)
          ..where((c) => c.academicCourseId.equals(classId)))
        .get();

    List<int> studentIds = [];
    if (courseClasses.isNotEmpty) {
      final classIds = courseClasses.map((c) => c.id).toList();
      final enrollments = await (db.select(db.courseClassEnrollments)
            ..where((e) => e.courseClassId.isIn(classIds)))
          .get();
      studentIds = enrollments.map((e) => e.studentId).toSet().toList();
    }

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

      final cls = await (db.select(db.classes)
            ..where((c) => c.id.equals(resolvedClassId)))
          .getSingleOrNull();

      EmailService.notifyNewAssignment(
        db: db,
        studentIds: studentIds,
        assignmentTitle: title,
        className: cls?.className ?? 'Lớp học',
        dueDate: dueDate,
      );
    }

    return Response.json(body: {
      'message': 'Assignment created successfully',
      'assignmentId': assignmentId,
      'moduleId': moduleId,
      'studentsAssigned': studentIds.length,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': '$e'},
    );
  }
}
