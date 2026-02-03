import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  if (!params.containsKey('userId')) {
    return Response(statusCode: 400, body: 'Missing userId');
  }
  final studentId = int.parse(params['userId']!);
  try {
    final query = db.select(db.studentAssignments).join([
      innerJoin(
        db.assignments,
        db.assignments.id.equalsExp(db.studentAssignments.assignmentId),
      ),
      leftOuterJoin(
        db.classes,
        db.classes.id.equalsExp(db.assignments.classId),
      ),
    ])
      ..where(db.studentAssignments.studentId.equals(studentId));
    final results = await query.get();
    final assignments = results.map((row) {
      final studentAssignment = row.readTable(db.studentAssignments);
      final assignment = row.readTable(db.assignments);
      final classInfo = row.readTableOrNull(db.classes);
      return {
        'id': assignment.id,
        'studentAssignmentId': studentAssignment.id,
        'title': assignment.title,
        'description': assignment.description,
        'dueDate': assignment.dueDate.toIso8601String(),
        'rewardPoints': assignment.rewardPoints,
        'createdAt': assignment.createdAt.toIso8601String(),
        'isCompleted': studentAssignment.isCompleted,
        'completedAt': studentAssignment.completedAt?.toIso8601String(),
        'rewardClaimed': studentAssignment.rewardClaimed,
        'className': classInfo?.className,
        'classId': assignment.classId,
      };
    }).toList();
    return Response.json(body: assignments);
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}