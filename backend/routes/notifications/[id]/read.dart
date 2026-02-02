import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: 405);
  }
  final db = context.read<AppDatabase>();
  final notificationId = int.parse(id);
  try {
    final updated = await (db.update(db.notifications)
          ..where((n) => n.id.equals(notificationId)))
        .write(
      NotificationsCompanion(
        isRead: const Value(true),
      ),
    );
    if (updated == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Notification not found'},
      );
    }
    return Response.json(
      body: {'success': true, 'message': 'Notification marked as read'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}