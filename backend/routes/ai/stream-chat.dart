import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/services/embedding_service.dart';
import 'package:backend/helpers/env_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final lessonTitle = body['lessonTitle'] as String?;
    final lessonId = body['lessonId'] as int?;
    final textContent = body['textContent'] as String?;
    final question = body['question'] as String?;
    final imageBase64 = body['imageBase64'] as String?;

    if (lessonTitle == null || question == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'lessonTitle and question are required'},
      );
    }

    final rawHistory = body['history'] as List<dynamic>? ?? [];
    final history = rawHistory.map((h) {
      final m = h as Map<String, dynamic>;
      return {
        'role': m['role'] as String? ?? 'user',
        'content': m['content'] as String? ?? '',
      };
    }).toList();

    final persona = body['persona'] as String?;

    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    final db = context.read<AppDatabase>();
    var resolvedContent = textContent ?? '';

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

    int? userId;
    try {
      userId = context.read<int>();
    } catch (_) {}

    String? userProfileContext;
    if (userId != null) {
      final studentProfile = await (db.select(db.studentProfiles)
            ..where((p) => p.userId.equals(userId!)))
          .getSingleOrNull();

      if (studentProfile != null) {
        final major = studentProfile.major;
        final year = studentProfile.academicYear;
        if (major != null || year != null) {
          final yearText = year != null ? ' ($year)' : '';
          final majorText = major != null ? ' chuyên ngành $major' : '';
          userProfileContext =
              'Người hỏi là sinh viên đại học$yearText$majorText, hãy giải thích bằng các thuật ngữ chuyên ngành khoa học máy tính.';
        } else {
          userProfileContext =
              'Người hỏi là sinh viên đại học, hãy giải thích bằng các thuật ngữ chuyên ngành khoa học máy tính.';
        }
      }
    }

    final aiService = AIService(openaiApiKey: apiKey);
    final stream = aiService.chatWithContextStream(
      lessonTitle: lessonTitle,
      textContent: resolvedContent,
      history: history,
      question: question,
      persona: persona,
      userProfileContext: userProfileContext,
      imageBase64: imageBase64,
    );

    final controller = StreamController<List<int>>();

    () async {
      try {
        await for (final token in stream) {
          final event = 'data: ${jsonEncode({'token': token})}\n\n';
          controller.add(utf8.encode(event));
        }
        controller.add(utf8.encode('data: [DONE]\n\n'));
      } catch (e) {
        final errorEvent = 'data: ${jsonEncode({'error': e.toString()})}\n\n';
        controller.add(utf8.encode(errorEvent));
      } finally {
        await controller.close();
      }
    }();

    return Response.stream(
      statusCode: HttpStatus.ok,
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'X-Accel-Buffering': 'no',
      },
      body: controller.stream,
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Stream chat failed: $e'},
    );
  }
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
                1 - (embedding <=> '$vecSql'::vector) AS score
         FROM video_segments
         WHERE lesson_id = $lessonId AND embedding IS NOT NULL
         ORDER BY embedding <=> '$vecSql'::vector
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
