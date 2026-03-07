import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();
  try {
    await db.customStatement(
      'ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT',
    );
    return Response.json(body: {'message': 'Migration done: fcm_token added'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Migration failed: $e'},
    );
  }
}
