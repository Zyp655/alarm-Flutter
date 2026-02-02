import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final notificationId = int.parse(id);
  try {
    final deleted = await (db.delete(db.notifications)
          ..where((n) => n.id.equals(notificationId)))
        .go();
    if (deleted == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Notification not found'},
      );
    }
    return Response.json(
      body: {'success': true, 'message': 'Notification deleted'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}