import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/services/embedding_service.dart';
import 'package:backend/helpers/env_helper.dart';
import 'package:drift/drift.dart';

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

    final db = context.read<AppDatabase>();
    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    String segmentContent = '';
    String segmentSummary = '';
    String adjacentContext = '';
    var ragSource = 'fallback';

    if (lessonId != null) {
      final vectorResult = await _retrieveByVector(db, apiKey, lessonId, lessonTitle, timestamp);
      if (vectorResult.isNotEmpty) {
        segmentContent = vectorResult['transcript'] ?? '';
        segmentSummary = vectorResult['summary'] ?? '';
        adjacentContext = vectorResult['adjacentContext'] ?? '';
        ragSource = 'vector_semantic';
      }

      if (segmentContent.isEmpty) {
        final tsResult = await _retrieveByTimestamp(db, lessonId, timestamp);
        if (tsResult.isNotEmpty) {
          segmentContent = tsResult['transcript'] ?? '';
          segmentSummary = tsResult['summary'] ?? '';
          adjacentContext = tsResult['adjacentContext'] ?? '';
          ragSource = 'timestamp_match';
        }
      }

      if (segmentContent.isEmpty) {
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
          ragSource = 'transcript_slice';
        } else if (lesson != null &&
            lesson.textContent != null &&
            lesson.textContent!.length > 10) {
          segmentContent = _extractSegment(
            lesson.textContent!,
            timestamp,
            totalDuration,
          );
          ragSource = 'text_slice';
        }
      }
    }

    final hasTranscript = segmentContent.length > 10;
    final hasRAG = ragSource == 'vector_semantic';

    final prompt = '''
Bạn là trợ lý AI học tập. Sinh viên đang xem video bài học "$lessonTitle" và gặp khó khăn tại phút $timeStr.

Dấu hiệu bối rối:
- Số lần pause: ${confusionSignals['pauseCount'] ?? 0}
- Số lần rewind: ${confusionSignals['rewindCount'] ?? 0}
- Emotion detected: ${confusionSignals['emotion'] ?? 'confused'}

${hasTranscript ? '''Nội dung video tại đoạn gây khó khăn (phút $timeStr):
${hasRAG ? '(Transcript chính xác từ semantic search - nguồn RAG vector)' : '(Transcript ước lượng)'}
"""
$segmentContent
"""

${segmentSummary.isNotEmpty ? 'Tóm tắt phân đoạn: $segmentSummary' : ''}
${adjacentContext.isNotEmpty ? '\nNgữ cảnh bài giảng xung quanh:\n$adjacentContext' : ''}''' : '''Nội dung chi tiết của video chưa có sẵn.
Dựa vào chủ đề bài học "$lessonTitle" và thời điểm phút $timeStr/${totalDuration ~/ 60} phút tổng.'''}

QUAN TRỌNG: Trả lời theo format JSON sau (CHỈ JSON, KHÔNG có text khác):
{
  "contentPoints": [
    "Nội dung chính 1 đang được giảng tại thời điểm này",
    "Nội dung chính 2 đang được giảng tại thời điểm này",
    "Nội dung chính 3 (nếu có)"
  ],
  "summary": "Tóm tắt ngắn gọn 1-2 câu về nội dung đoạn này"
}

Yêu cầu:
- contentPoints: Liệt kê 2-4 ý chính đang được giảng tại thời điểm này, mỗi ý ngắn gọn (1-2 câu)
- summary: Tóm tắt ngắn gọn nội dung đoạn video
- Viết bằng tiếng Việt, dễ hiểu
- ${hasRAG ? 'Dựa chính xác vào nội dung transcript đã cung cấp, KHÔNG suy luận ngoài phạm vi' : 'Dựa vào nội dung có sẵn để giải thích'}
''';

    final aiService = AIService(openaiApiKey: apiKey);
    final raw = await aiService.generateExplanation(prompt);

    List<String> contentPoints = [];
    String summary = raw;

    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
      if (jsonMatch != null) {
        final parsed =
            (await Future.value(jsonDecode(jsonMatch.group(0)!)))
                as Map<String, dynamic>;
        final pts = parsed['contentPoints'] as List<dynamic>?;
        if (pts != null) {
          contentPoints = pts.map((e) => e.toString()).toList();
        }
        summary = parsed['summary'] as String? ?? raw;
      }
    } catch (_) {
      final lines = raw.split('\n');
      for (final line in lines) {
        final match = RegExp(r'^\d+[\.\\)]\s*(.+)').firstMatch(line.trim());
        if (match != null) contentPoints.add(match.group(1)!);
      }
      if (contentPoints.isEmpty) contentPoints = [raw];
    }

    return Response.json(body: {
      'success': true,
      'explanation': summary,
      'contentPoints': contentPoints,
      'timestamp': timestamp,
      'timeStr': timeStr,
      'lessonTitle': lessonTitle,
      'hasTranscript': hasTranscript,
      'ragSource': ragSource,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to generate explanation: $e'},
    );
  }
}

Future<Map<String, String>> _retrieveByVector(
  AppDatabase db,
  String apiKey,
  int lessonId,
  String lessonTitle,
  int timestamp,
) async {
  try {
    final embeddingService = EmbeddingService(openaiApiKey: apiKey, db: db);
    final minutes = timestamp ~/ 60;
    final queryText = '$lessonTitle - nội dung tại phút $minutes';
    final queryVec = await embeddingService.generateEmbedding(queryText);
    if (queryVec.isEmpty) return {};

    final vecSql = '[${queryVec.join(',')}]';
    final rows = await db.customSelect(
      '''SELECT id, segment_index, start_timestamp, end_timestamp,
                transcript, summary,
                1 - (embedding <=> '$vecSql'::vector) AS score
         FROM video_segments
         WHERE lesson_id = $lessonId AND embedding IS NOT NULL
         ORDER BY embedding <=> '$vecSql'::vector
         LIMIT 3''',
    ).get();

    if (rows.isEmpty) return {};

    final best = rows.first;
    final transcript = best.read<String>('transcript');
    final summary = best.readNullable<String>('summary') ?? '';

    final adjacentSummaries = <String>[];
    for (var i = 1; i < rows.length; i++) {
      final adj = rows[i].readNullable<String>('summary');
      if (adj != null && adj.isNotEmpty) {
        adjacentSummaries.add('Phần liên quan: $adj');
      }
    }

    return {
      'transcript': transcript,
      'summary': summary,
      'adjacentContext': adjacentSummaries.join('\n'),
    };
  } catch (_) {
    return {};
  }
}

Future<Map<String, String>> _retrieveByTimestamp(
  AppDatabase db,
  int lessonId,
  int timestamp,
) async {
  try {
    final tsDouble = timestamp.toDouble();
    final segments = await (db.select(db.videoSegments)
          ..where((s) => s.lessonId.equals(lessonId))
          ..orderBy([(s) => OrderingTerm.asc(s.startTimestamp)]))
        .get();

    if (segments.isEmpty) return {};

    VideoSegment? matchingSegment;
    for (final seg in segments) {
      if (tsDouble >= seg.startTimestamp && tsDouble <= seg.endTimestamp) {
        matchingSegment = seg;
        break;
      }
    }

    matchingSegment ??= segments.reduce((a, b) {
      final distA = (a.startTimestamp - tsDouble).abs();
      final distB = (b.startTimestamp - tsDouble).abs();
      return distA < distB ? a : b;
    });

    final adjacentSummaries = <String>[];
    final idx = segments.indexOf(matchingSegment);

    if (idx > 0) {
      final prev = segments[idx - 1];
      if (prev.summary != null && prev.summary!.isNotEmpty) {
        adjacentSummaries.add('Phần trước: ${prev.summary}');
      }
    }
    if (idx < segments.length - 1) {
      final next = segments[idx + 1];
      if (next.summary != null && next.summary!.isNotEmpty) {
        adjacentSummaries.add('Phần sau: ${next.summary}');
      }
    }

    return {
      'transcript': matchingSegment.transcript,
      'summary': matchingSegment.summary ?? '',
      'adjacentContext': adjacentSummaries.join('\n'),
    };
  } catch (_) {
    return {};
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
