import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/helpers/env_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final lessonTitle = body['lessonTitle'] as String? ?? '';
    final lessonId = body['lessonId'] as int?;
    final timestamp = body['timestamp'] as int? ?? 0;
    final totalDuration = body['totalDuration'] as int? ?? 0;
    final confusionSignals =
        body['confusionSignals'] as Map<String, dynamic>? ?? {};

    final minutes = timestamp ~/ 60;
    final seconds = timestamp % 60;
    final timeStr = '${minutes}:${seconds.toString().padLeft(2, '0')}';

    String segmentContent = '';

    if (lessonId != null) {
      final db = context.read<AppDatabase>();
      final lesson = await (db.select(db.lessons)
            ..where((t) => t.id.equals(lessonId)))
          .getSingleOrNull();

      if (lesson != null &&
          lesson.cachedTranscript != null &&
          lesson.cachedTranscript!.length > 10) {
        segmentContent = _extractSegment(
          lesson.cachedTranscript!,
          timestamp,
          totalDuration,
        );
      } else if (lesson != null &&
          lesson.textContent != null &&
          lesson.textContent!.length > 10) {
        segmentContent = _extractSegment(
          lesson.textContent!,
          timestamp,
          totalDuration,
        );
      }
    }

    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    final hasTranscript = segmentContent.length > 10;

    final prompt = '''
Bạn là trợ lý AI học tập. Sinh viên đang xem video bài học "$lessonTitle" và gặp khó khăn tại phút $timeStr.

Dấu hiệu bối rối:
- Số lần pause: ${confusionSignals['pauseCount'] ?? 0}
- Số lần rewind: ${confusionSignals['rewindCount'] ?? 0}
- Emotion detected: ${confusionSignals['emotion'] ?? 'confused'}

${hasTranscript ? '''Nội dung video tại đoạn gây khó khăn (phút $timeStr):
"""
$segmentContent
"""

Hãy:
1. Giải thích lại nội dung đoạn này một cách đơn giản, dễ hiểu
2. Cho ví dụ minh họa thực tế
3. Tóm tắt các ý chính bằng bullet points''' : '''Nội dung chi tiết của video chưa có sẵn.
Dựa vào chủ đề bài học "$lessonTitle" và thời điểm phút $timeStr/${totalDuration ~/ 60} phút tổng:

Hãy:
1. Suy đoán nội dung có thể được dạy tại thời điểm này
2. Giải thích các khái niệm quan trọng cho chủ đề này
3. Cho ví dụ minh họa thực tế'''}

Trả lời bằng tiếng Việt, ngắn gọn, dễ hiểu (tối đa 150 từ).
''';

    final aiService = AIService(openaiApiKey: apiKey);
    final explanation = await aiService.generateExplanation(prompt);

    return Response.json(body: {
      'success': true,
      'explanation': explanation,
      'timestamp': timestamp,
      'timeStr': timeStr,
      'lessonTitle': lessonTitle,
      'hasTranscript': hasTranscript,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to generate explanation: $e'},
    );
  }
}

String _extractSegment(String transcript, int timestamp, int totalDuration) {
  final words = transcript.split(RegExp(r'\s+'));
  final totalWords = words.length;

  if (totalDuration <= 0 || totalWords <= 20) return transcript;

  final wordsPerSecond = totalWords / totalDuration;
  final windowStart = (timestamp - 120).clamp(0, totalDuration);
  final windowEnd = (timestamp + 30).clamp(0, totalDuration);

  final startWord = (windowStart * wordsPerSecond).round().clamp(0, totalWords);
  final endWord = (windowEnd * wordsPerSecond).round().clamp(0, totalWords);

  if (endWord <= startWord) return transcript;

  return words.sublist(startWord, endWord).join(' ');
}
