import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/helpers/env_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final question = body['question'] as String?;

    if (question == null || question.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'question is required'},
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

    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    final aiService = AIService(openaiApiKey: apiKey);
    final stream = aiService.chatWithAssistantStream(
      history: history,
      question: question,
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
      body: {'error': 'Stream assistant failed: $e'},
    );
  }
}
