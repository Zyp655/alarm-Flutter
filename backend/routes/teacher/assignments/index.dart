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
    return Response(statusCode: 400, body: ' Missing userId');
  }

  final teacherId = int.parse(params['userId']!);
  final classId =
      params['classId'] != null ? int.tryParse(params['classId']!) : null;

  try {
    var query = db.select(db.assignments).join([
      leftOuterJoin(
        db.studentAssignments,
        db.studentAssignments.assignmentId.equalsExp(db.assignments.id),
      ),
    ])
      ..where(db.assignments.teacherId.equals(teacherId));

    if (classId != null) {
      query = query..where(db.assignments.classId.equals(classId));
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
        };
      }

      if (studentAssignment != null) {
        assignmentMap[assignment.id]!['totalStudents'] += 1;
        if (studentAssignment.isCompleted) {
          assignmentMap[assignment.id]!['completedStudents'] += 1;
        }
      }
    }

    return Response.json(body: assignmentMap.values.toList());
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
