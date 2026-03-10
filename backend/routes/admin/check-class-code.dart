import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final classCode = context.request.uri.queryParameters['classCode'];
  final courseIdStr = context.request.uri.queryParameters['academicCourseId'];

  if (classCode == null || classCode.trim().isEmpty) {
    return Response.json(body: {'exists': false});
  }

  try {
    final db = context.read<AppDatabase>();
    var query = db.select(db.courseClasses)
      ..where((c) => c.classCode.equals(classCode.trim()));

    final courseId = int.tryParse(courseIdStr ?? '');
    if (courseId != null) {
      query = query..where((c) => c.academicCourseId.equals(courseId));
    }

    final existing = await query.getSingleOrNull();

    return Response.json(body: {
      'exists': existing != null,
      'classCode': classCode.trim(),
    });
  } catch (e) {
    return Response.json(body: {'exists': false});
  }
}
