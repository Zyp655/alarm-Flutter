import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final assignmentId = int.tryParse(id);

  if (assignmentId == null) {
    return Response(statusCode: 400, body: 'Invalid assignment ID');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final teacherId = body['teacherId'] as int?;
    final title = body['title'] as String?;
    final description = body['description'] as String?;
    final dueDateStr = body['dueDate'] as String?;
    final rewardPoints = body['rewardPoints'] as int?;

    if (teacherId == null) {
      return Response(statusCode: 400, body: 'Missing teacherId');
    }

   
    final existingAssignment = await (db.select(db.assignments)
          ..where((a) => a.id.equals(assignmentId))
          ..where((a) => a.teacherId.equals(teacherId)))
        .getSingleOrNull();

    if (existingAssignment == null) {
      return Response(
        statusCode: 404,
        body: 'Assignment not found or unauthorized',
      );
    }

    DateTime? dueDate;
    if (dueDateStr != null) {
      try {
        dueDate = DateTime.parse(dueDateStr);
      } catch (e) {
        return Response(statusCode: 400, body: 'Invalid dueDate format');
      }
    }

    await (db.update(db.assignments)..where((a) => a.id.equals(assignmentId)))
        .write(
      AssignmentsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
        rewardPoints:
            rewardPoints != null ? Value(rewardPoints) : const Value.absent(),
      ),
    );

    final updatedAssignment = await (db.select(db.assignments)
          ..where((a) => a.id.equals(assignmentId)))
        .getSingle();

    return Response.json(body: {
      'message': 'Assignment updated successfully',
      'assignment': {
        'id': updatedAssignment.id,
        'classId': updatedAssignment.classId,
        'title': updatedAssignment.title,
        'description': updatedAssignment.description,
        'dueDate': updatedAssignment.dueDate.toIso8601String(),
        'rewardPoints': updatedAssignment.rewardPoints,
        'createdAt': updatedAssignment.createdAt.toIso8601String(),
      },
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
