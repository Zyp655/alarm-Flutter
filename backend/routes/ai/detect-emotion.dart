import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/services/request_deduplicator.dart';
import 'package:backend/helpers/env_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final imageBase64 = body['imageBase64'] as String?;
    final userId = body['userId'] as int?;

    if (imageBase64 == null || imageBase64.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'imageBase64 is required'},
      );
    }

    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    final aiService = AIService(openaiApiKey: apiKey);
    final dedup = RequestDeduplicator();

    final imageHash = imageBase64.length > 100
        ? imageBase64.substring(0, 50) + imageBase64.substring(imageBase64.length - 50)
        : imageBase64;

    final result = await dedup.deduplicate<Map<String, dynamic>>(
      category: 'emotion',
      params: {'hash': imageHash.hashCode, 'userId': userId ?? 0},
      execute: () => aiService.analyzeEmotion(imageBase64: imageBase64),
      cacheTtlSeconds: 10,
    );

    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Emotion detection failed: $e'},
    );
  }
}
