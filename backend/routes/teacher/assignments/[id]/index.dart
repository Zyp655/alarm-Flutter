import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final assignmentId = int.tryParse(id);
  if (assignmentId == null) {
    return Response(statusCode: 400, body: 'Invalid assignment id');
  }

  try {
    await db.customStatement(
      'DELETE FROM student_assignments WHERE assignment_id = $assignmentId',
    );
    await db.customStatement(
      'DELETE FROM assignments WHERE id = $assignmentId',
    );
    return Response.json(body: {'message': 'Deleted'});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': '$e'});
  }
}
