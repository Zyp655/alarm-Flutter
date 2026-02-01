import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/services/transcription_service.dart';
import 'package:dotenv/dotenv.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final moduleId = int.tryParse(id);
  if (moduleId == null) {
    return Response(
        statusCode: HttpStatus.badRequest, body: 'Invalid Module ID');
  }
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  try {
    final db = context.read<AppDatabase>();
    final module = await (db.select(db.modules)
          ..where((t) => t.id.equals(moduleId)))
        .getSingleOrNull();
    if (module == null) {
      return Response(
          statusCode: HttpStatus.notFound, body: 'Module not found');
    }
    final lessons = await (db.select(db.lessons)
          ..where((t) => t.moduleId.equals(moduleId)))
        .get();
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final apiKey = env['OPENAI_API_KEY'];
    if (apiKey == null) {
      return Response(
          statusCode: HttpStatus.internalServerError,
          body: 'AI Config Missing');
    }
    final transcriptionService = TranscriptionService(openaiApiKey: apiKey);
    final contentBuffer = StringBuffer();
    for (final lesson in lessons) {
      contentBuffer.writeln('\n--- Lesson: ${lesson.title} ---');
      if (lesson.textContent != null && lesson.textContent!.isNotEmpty) {
        contentBuffer.writeln(lesson.textContent);
      }
      if (lesson.contentUrl != null && lesson.type == 'video') {
        final videoUrl = lesson.contentUrl!;
        print('[Quiz Generate] Found video lesson: ${lesson.title}');
        print('[Quiz Generate] Video URL: $videoUrl');
        print(
            '[Quiz Generate] Is transcribable: ${transcriptionService.isTranscribableUrl(videoUrl)}');
        if (transcriptionService.isTranscribableUrl(videoUrl)) {
          try {
            print('[Quiz Generate] Starting transcription...');
            final transcript =
                await transcriptionService.transcribeFromUrl(videoUrl);
            if (transcript.isNotEmpty) {
              print(
                  '[Quiz Generate] Transcription success! Length: ${transcript.length}');
              contentBuffer.writeln('\n[Video Transcript]:');
              contentBuffer.writeln(transcript);
            }
          } catch (e) {
            print('[Quiz Generate] Transcription ERROR: $e');
            contentBuffer.writeln(
                '(Video content could not be transcribed: ${e.toString()})');
          }
        } else {
          print(
              '[Quiz Generate] Video URL not transcribable (external or no extension)');
          contentBuffer.writeln(
              '(Video URL: $videoUrl - external video, cannot transcribe)');
        }
      } else if (lesson.contentUrl != null) {
        print(
            '[Quiz Generate] Lesson has contentUrl but type is: ${lesson.type}');
        contentBuffer.writeln('(Content Reference: ${lesson.contentUrl})');
      } else {
        print('[Quiz Generate] Lesson ${lesson.title} has no contentUrl');
      }
    }
    String fullContent = contentBuffer.toString();
    if (fullContent.trim().length < 50) {
      return Response(
          statusCode: HttpStatus.badRequest,
          body: jsonEncode({
            'error':
                'Not enough content in this module to generate a quiz. Please add lesson content first.'
          }));
    }
    if (fullContent.length > 100000) {
      fullContent = fullContent.substring(0, 100000);
    }
    final aiService = AIService(openaiApiKey: apiKey);
    final result = await aiService.generateQuizFromContext(
      context: fullContent,
      moduleTitle: module.title,
    );
    return Response.json(body: result);
  } catch (e) {
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: jsonEncode({'error': e.toString()}));
  }
}