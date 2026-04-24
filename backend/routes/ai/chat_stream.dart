import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/helpers/env_helper.dart';
import 'package:backend/services/embedding_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final env = loadEnv();
  final apiKey = env['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    return Response(statusCode: 500, body: 'OpenAI API key not configured');
  }

  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((message) async {
      try {
        final body = jsonDecode(message as String) as Map<String, dynamic>;

        final lessonTitle = body['lessonTitle'] as String?;
        final textContent = body['textContent'] as String?;
        final question = body['question'] as String?;
        final lessonId = body['lessonId'] as int?;
        final persona = body['persona'] as String?;
        final imageBase64 = body['imageBase64'] as String?;

        if (lessonTitle == null || question == null) {
          channel.sink.add(jsonEncode({'error': 'lessonTitle and question required'}));
          return;
        }

        final rawHistory = body['history'] as List<dynamic>? ?? [];
        final history = rawHistory.map((h) {
          final m = h as Map<String, dynamic>;
          return {
            'role': m['role'] as String? ?? 'user',
            'content': m['content'] as String? ?? '',
          };
        }).toList();

        final db = context.read<AppDatabase>();
        var resolvedContent = textContent ?? '';

        // If lessonId is provided, try to fetch relevant segments via embeddings
        if (lessonId != null && resolvedContent.length < 20) {
          final vectorContent = await _retrieveRelevantSegments(db, apiKey, lessonId, question);
          if (vectorContent.isNotEmpty) {
            resolvedContent = vectorContent;
          } else {
            final lesson = await (db.select(db.lessons)
                  ..where((l) => l.id.equals(lessonId)))
                .getSingleOrNull();
            if (lesson != null) {
              resolvedContent = lesson.cachedTranscript ?? lesson.textContent ?? '';
            }
          }
        }

        final aiService = AIService(openaiApiKey: apiKey);
        final stream = aiService.streamChatWithAudioChunking(
          lessonTitle: lessonTitle,
          textContent: resolvedContent,
          history: history,
          question: question,
          persona: persona,
          imageBase64: imageBase64,
        );

        stream.listen(
          (data) {
            channel.sink.add(jsonEncode(data));
          },
          onDone: () {
            channel.sink.add(jsonEncode({'type': 'done'}));
            channel.sink.close();
          },
          onError: (e) {
            channel.sink.add(jsonEncode({'error': 'Stream error: $e'}));
            channel.sink.close();
          },
        );
      } catch (e) {
        channel.sink.add(jsonEncode({'error': 'Processing error: $e'}));
        channel.sink.close();
      }
    });
  });

  return handler(context);
}

Future<String> _retrieveRelevantSegments(
  AppDatabase db,
  String apiKey,
  int lessonId,
  String question,
) async {
  try {
    final embeddingService = EmbeddingService(openaiApiKey: apiKey, db: db);
    final queryVec = await embeddingService.generateEmbedding(question);
    if (queryVec.isEmpty) return '';

    final vecSql = '[${queryVec.join(',')}]';
    final rows = await db.customSelect(
      '''SELECT transcript, summary,
                1 - (embedding <=> '\$vecSql'::vector) AS score
         FROM video_segments
         WHERE lesson_id = $lessonId AND embedding IS NOT NULL
         ORDER BY embedding <=> '\$vecSql'::vector
         LIMIT 5''',
    ).get();

    if (rows.isEmpty) return '';

    final parts = <String>[];
    for (var i = 0; i < rows.length; i++) {
      final transcript = rows[i].read<String>('transcript');
      final summary = rows[i].readNullable<String>('summary') ?? '';
      final score = rows[i].read<double>('score');
      if (score < 0.3) continue;
      parts.add('=== Đoạn ${i + 1} (relevance: ${(score * 100).toStringAsFixed(0)}%) ===\n'
          '${summary.isNotEmpty ? "Tóm tắt: $summary\n" : ""}'
          '$transcript');
    }

    return parts.join('\n\n');
  } catch (_) {
    return '';
  }
}
