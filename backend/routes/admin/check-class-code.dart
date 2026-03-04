import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';


Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final classCode = context.request.uri.queryParameters['classCode'];
  if (classCode == null || classCode.trim().isEmpty) {
    return Response.json(body: {'exists': false});
  }

  try {
    final db = context.read<AppDatabase>();
    final existing = await (db.select(db.courseClasses)
          ..where((c) => c.classCode.equals(classCode.trim())))
        .getSingleOrNull();

    return Response.json(body: {
      'exists': existing != null,
      'classCode': classCode.trim(),
    });
  } catch (e) {
    return Response.json(body: {'exists': false});
  }
}
