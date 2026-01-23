import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final assignmentId = int.tryParse(id);

  if (assignmentId == null) {
    return Response(statusCode: 400, body: 'Invalid assignment ID');
  }

  try {
    final params = context.request.uri.queryParameters;
    final teacherId =
        params['teacherId'] != null ? int.tryParse(params['teacherId']!) : null;

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

    await (db.delete(db.studentAssignments)
          ..where((sa) => sa.assignmentId.equals(assignmentId)))
        .go();

    final deletedCount = await (db.delete(db.assignments)
          ..where((a) => a.id.equals(assignmentId)))
        .go();

    if (deletedCount > 0) {
      return Response.json(body: {
        'message': 'Assignment deleted successfully',
        'assignmentId': assignmentId,
      });
    } else {
      return Response(statusCode: 404, body: 'Assignment not found');
    }
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
