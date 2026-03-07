import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/services/ai_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final videoUrl = body['videoUrl'] as String?;

    if (videoUrl == null || videoUrl.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'videoUrl is required'},
      );
    }

    final env = DotEnv(includePlatformEnvironment: true)..load();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'OpenAI API key not configured'},
      );
    }

    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    try {
      final videoResponse = await http.get(Uri.parse(videoUrl));
      if (videoResponse.statusCode != 200) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Cannot download video: ${videoResponse.statusCode}'},
        );
      }
      await tempFile.writeAsBytes(videoResponse.bodyBytes);

      final fileSizeMB = await tempFile.length() / (1024 * 1024);
      if (fileSizeMB > 25) {
        await tempFile.delete();
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'error':
                'Video too large (${fileSizeMB.toStringAsFixed(1)}MB). Max 25MB for Whisper API.',
          },
        );
      }

      final aiService = AIService(openaiApiKey: apiKey);
      final transcript = await aiService.speechToText(tempFile);

      await tempFile.delete();

      return Response.json(body: {'transcript': transcript});
    } catch (e) {
      if (await tempFile.exists()) await tempFile.delete();
      rethrow;
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Video transcription failed: $e'},
    );
  }
}
