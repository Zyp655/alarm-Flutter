import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/embedding_service.dart';
import 'package:backend/helpers/env_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final env = loadEnv();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    final db = context.read<AppDatabase>();
    final embeddingService = EmbeddingService(openaiApiKey: apiKey, db: db);
    final result = await embeddingService.embedAllMissing();

    return Response.json(body: {
      'success': true,
      'embedded': result,
      'total': (result['courses'] ?? 0) + (result['lessons'] ?? 0) + (result['segments'] ?? 0),
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Embedding sync failed: $e'},
    );
  }
}
