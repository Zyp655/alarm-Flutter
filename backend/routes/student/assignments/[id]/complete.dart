import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;

  final studentId = body['studentId'] as int?;
  if (studentId == null) {
    return Response(statusCode: 400, body: 'Missing studentId');
  }

  final studentAssignmentId = int.tryParse(id);
  if (studentAssignmentId == null) {
    return Response(statusCode: 400, body: 'Invalid assignment ID');
  }

  try {
    final query = db.select(db.studentAssignments).join([
      innerJoin(
        db.assignments,
        db.assignments.id.equalsExp(db.studentAssignments.assignmentId),
      ),
    ])
      ..where(db.studentAssignments.id.equals(studentAssignmentId))
      ..where(db.studentAssignments.studentId.equals(studentId));

    final result = await query.getSingleOrNull();

    if (result == null) {
      return Response(statusCode: 404, body: 'Assignment not found');
    }

    final studentAssignment = result.readTable(db.studentAssignments);
    final assignment = result.readTable(db.assignments);

    if (studentAssignment.isCompleted) {
      return Response.json(body: {
        'message': 'Assignment already completed',
        'completedAt': studentAssignment.completedAt?.toIso8601String(),
        'rewardClaimed': studentAssignment.rewardClaimed,
      });
    }

    await (db.update(db.studentAssignments)
          ..where((sa) => sa.id.equals(studentAssignmentId)))
        .write(
      StudentAssignmentsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
        rewardClaimed: const Value(true),
      ),
    );

    

    return Response.json(body: {
      'message': 'Assignment completed successfully!',
      'rewardPoints': assignment.rewardPoints,
      'completedAt': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    print('❌ ERROR completing assignment: $e');
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
