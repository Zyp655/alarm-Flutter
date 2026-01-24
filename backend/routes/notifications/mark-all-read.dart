import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;

  if (!params.containsKey('userId')) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing userId parameter'},
    );
  }

  final userId = int.parse(params['userId']!);

  try {
    final updated = await (db.update(db.notifications)
          ..where((n) => n.userId.equals(userId)))
        .write(
      NotificationsCompanion(
        isRead: const Value(true),
      ),
    );

    return Response.json(
      body: {
        'success': true,
        'message': 'All notifications marked as read',
        'count': updated,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
