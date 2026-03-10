import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  final lessonId = int.tryParse(params['lessonId'] ?? '');

  if (lessonId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'lessonId is required'},
    );
  }

  final segments = await (db.select(db.videoSegments)
        ..where((s) => s.lessonId.equals(lessonId))
        ..orderBy([(s) => OrderingTerm.asc(s.segmentIndex)]))
      .get();

  final userId = int.tryParse(params['userId'] ?? '0') ?? 0;

  final result = <Map<String, dynamic>>[];
  for (final seg in segments) {
    Map<String, dynamic>? attemptData;
    if (userId > 0) {
      final attempt = await (db.select(db.segmentQuizAttempts)
            ..where((a) => a.studentId.equals(userId))
            ..where((a) => a.segmentId.equals(seg.id)))
          .getSingleOrNull();
      if (attempt != null) {
        attemptData = {
          'attemptCount': attempt.attemptCount,
          'passed': attempt.passed,
        };
      }
    }

    result.add({
      'id': seg.id,
      'segmentIndex': seg.segmentIndex,
      'startTimestamp': seg.startTimestamp,
      'endTimestamp': seg.endTimestamp,
      'transcript': seg.transcript,
      'summary': seg.summary,
      'quizQuestion': seg.quizQuestion,
      'attempt': attemptData,
    });
  }

  return Response.json(body: {
    'lessonId': lessonId,
    'segments': result,
  });
}
