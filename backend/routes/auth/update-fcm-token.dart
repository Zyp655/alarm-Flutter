import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final userId = data['userId'] as int?;
    final fcmToken = data['fcmToken'] as String?;

    if (userId == null || fcmToken == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'userId and fcmToken are required'},
      );
    }

    await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(fcmToken: Value(fcmToken)),
    );

    return Response.json(body: {'message': 'FCM token updated'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to update FCM token: $e'},
    );
  }
}
