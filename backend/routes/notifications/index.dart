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
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing userId parameter'},
    );
  }

  final userId = int.parse(params['userId']!);
  final limit = int.tryParse(params['limit'] ?? '50') ?? 50;
  final offset = int.tryParse(params['offset'] ?? '0') ?? 0;
  final unreadOnly = params['unreadOnly'] == 'true';

  try {
    var query = db.select(db.notifications)
      ..where((n) => n.userId.equals(userId));

    if (unreadOnly) {
      query = query..where((n) => n.isRead.equals(false));
    }

    query = query
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
      ..limit(limit, offset: offset);

    final notifications = await query.get();

    final result = notifications.map((n) {
      return {
        'id': n.id,
        'userId': n.userId,
        'type': n.type,
        'title': n.title,
        'message': n.message,
        'isRead': n.isRead,
        'actionUrl': n.actionUrl,
        'relatedId': n.relatedId,
        'relatedType': n.relatedType,
        'createdAt': n.createdAt.toIso8601String(),
      };
    }).toList();

    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
