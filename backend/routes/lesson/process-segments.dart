import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/video_segment_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;
  final lessonId = body['lessonId'] as int?;

  if (lessonId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'lessonId is required'},
    );
  }

  try {
    final service = VideoSegmentService(db);
    await service.processLesson(lessonId);

    final segments = await (db.select(db.videoSegments)
          ..where((s) => s.lessonId.equals(lessonId))
          ..orderBy([(s) => OrderingTerm.asc(s.segmentIndex)]))
        .get();

    return Response.json(body: {
      'lessonId': lessonId,
      'segmentCount': segments.length,
      'segments': segments
          .map((s) => {
                'id': s.id,
                'index': s.segmentIndex,
                'start': s.startTimestamp,
                'end': s.endTimestamp,
                'summary': s.summary,
              })
          .toList(),
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
