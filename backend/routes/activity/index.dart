import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final userId = body['userId'] as int?;
    final courseId = body['courseId'] as int?;
    final lessonId = body['lessonId'] as int?;
    final action = body['action']
        as String?;
    final metadata = body['metadata'] as String?;
    if (userId == null || courseId == null || action == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId, courseId, and action are required'},
      );
    }
    final validActions = [
      'join',
      'leave',
      'start_lesson',
      'complete_lesson',
      'pause',
      'resume'
    ];
    if (!validActions.contains(action)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid action. Valid actions: $validActions'},
      );
    }
    final id = await db.into(db.studentActivityLogs).insert(
          StudentActivityLogsCompanion.insert(
            userId: userId,
            courseId: courseId,
            lessonId: Value(lessonId),
            action: action,
            timestamp: DateTime.now(),
            metadata: Value(metadata),
          ),
        );
    await (db.update(db.enrollments)
          ..where((e) => e.userId.equals(userId) & e.courseId.equals(courseId)))
        .write(EnrollmentsCompanion(
      lastAccessedAt: Value(DateTime.now()),
    ));
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'message': 'Activity logged successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to log activity: $e'},
    );
  }
}