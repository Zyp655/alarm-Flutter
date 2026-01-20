import 'package:backend/database/database.dart';
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
        .where((s) => s.userId != null && s.userId != teacherId)
        .map((s) => s.userId!)
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

    return Response.json(body: {
      'message': 'Assignment created successfully',
      'assignmentId': assignmentId,
      'studentsAssigned': studentIds.length,
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
