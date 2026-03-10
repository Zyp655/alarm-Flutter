import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;
  final studentId = body['studentId'] as int?;
  final segmentId = body['segmentId'] as int?;
  final answerIndex = body['answerIndex'] as int?;

  if (studentId == null || segmentId == null || answerIndex == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'studentId, segmentId, answerIndex are required'},
    );
  }

  final segment = await (db.select(db.videoSegments)
        ..where((s) => s.id.equals(segmentId)))
      .getSingleOrNull();
  if (segment == null) {
    return Response.json(statusCode: 404, body: {'error': 'Segment not found'});
  }

  Map<String, dynamic> quiz;
  try {
    quiz = jsonDecode(segment.quizQuestion) as Map<String, dynamic>;
  } catch (_) {
    return Response.json(statusCode: 500, body: {'error': 'Invalid quiz data'});
  }

  final correctIndex = quiz['correctIndex'] as int? ?? 0;
  final isCorrect = answerIndex == correctIndex;

  var attempt = await (db.select(db.segmentQuizAttempts)
        ..where((a) => a.studentId.equals(studentId))
        ..where((a) => a.segmentId.equals(segmentId)))
      .getSingleOrNull();

  if (attempt == null) {
    final insertedId = await db.into(db.segmentQuizAttempts).insert(
          SegmentQuizAttemptsCompanion.insert(
            studentId: studentId,
            segmentId: segmentId,
          ),
        );
    attempt = await (db.select(db.segmentQuizAttempts)
          ..where((a) => a.id.equals(insertedId)))
        .getSingle();
  }

  final newCount = attempt.attemptCount + 1;
  final shouldRewind = !isCorrect && newCount >= 3;

  await (db.update(db.segmentQuizAttempts)
        ..where((a) => a.id.equals(attempt!.id)))
      .write(SegmentQuizAttemptsCompanion(
    attemptCount: Value(shouldRewind ? 0 : newCount),
    passed: Value(isCorrect),
    lastAttemptAt: Value(DateTime.now()),
  ));

  final startTs = segment.startTimestamp;
  final startMin = (startTs / 60).floor();
  final startSec = (startTs % 60).floor();
  final endTs = segment.endTimestamp;
  final endMin = (endTs / 60).floor();
  final endSec = (endTs % 60).floor();

  String? message;
  if (isCorrect) {
    message = 'Chính xác! Hãy tiếp tục bài học.';
  } else if (shouldRewind) {
    message =
        'Bạn cần xem lại kiến thức từ ${startMin.toString().padLeft(2, '0')}:${startSec.toString().padLeft(2, '0')} - ${endMin.toString().padLeft(2, '0')}:${endSec.toString().padLeft(2, '0')} để hoàn thành câu hỏi này.';
  } else {
    message = 'Sai rồi! Còn ${3 - newCount} lần thử.';
  }

  return Response.json(body: {
    'correct': isCorrect,
    'shouldRewind': shouldRewind,
    'rewindTo': shouldRewind ? startTs : null,
    'attemptCount': shouldRewind ? 0 : newCount,
    'message': message,
  });
}
