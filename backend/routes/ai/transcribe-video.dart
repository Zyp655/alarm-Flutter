import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/ai_service.dart';
import 'package:backend/helpers/env_helper.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final videoUrl = body['videoUrl'] as String?;
    final lessonId = body['lessonId'] as int?;

    if (videoUrl == null || videoUrl.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'videoUrl is required'},
      );
    }

    final db = context.read<AppDatabase>();

    if (lessonId != null) {
      final lesson = await (db.select(db.lessons)
            ..where((t) => t.id.equals(lessonId)))
          .getSingleOrNull();

      if (lesson != null && lesson.cachedTranscript != null && lesson.cachedTranscript!.isNotEmpty) {
        return Response.json(body: {
          'transcript': lesson.cachedTranscript,
          'cached': true,
        });
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

    final ts = DateTime.now().millisecondsSinceEpoch;
    final tempDir = Directory.systemTemp;
    final videoFile = File('${tempDir.path}/video_$ts.mp4');

    try {
      final videoResponse = await http.get(Uri.parse(videoUrl));
      if (videoResponse.statusCode != 200) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Cannot download video: ${videoResponse.statusCode}'},
        );
      }
      await videoFile.writeAsBytes(videoResponse.bodyBytes);

      final fileSizeMB = await videoFile.length() / (1024 * 1024);
      final aiService = AIService(openaiApiKey: apiKey);
      String fullTranscript;

      if (fileSizeMB <= 24) {
        fullTranscript = await aiService.speechToText(videoFile);
      } else {
        final hasFfmpeg = await _checkFfmpeg();
        if (!hasFfmpeg) {
          final first24MB = await _truncateFile(videoFile, 24 * 1024 * 1024);
          fullTranscript = await aiService.speechToText(first24MB);
          await _safeDelete(first24MB);
        } else {
          fullTranscript = await _transcribeWithFfmpeg(videoFile, aiService, tempDir, ts);
        }
      }

      await _safeDelete(videoFile);

      if (lessonId != null && fullTranscript.isNotEmpty) {
        await (db.update(db.lessons)..where((t) => t.id.equals(lessonId)))
            .write(LessonsCompanion(cachedTranscript: Value(fullTranscript)));
      }

      return Response.json(body: {
        'transcript': fullTranscript,
        'cached': false,
      });
    } catch (e) {
      await _safeDelete(videoFile);
      rethrow;
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Video transcription failed: $e'},
    );
  }
}

Future<bool> _checkFfmpeg() async {
  try {
    final result = await Process.run('ffmpeg', ['-version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<File> _truncateFile(File source, int maxBytes) async {
  final truncated = File('${source.path}_truncated.mp4');
  final bytes = await source.readAsBytes();
  final end = maxBytes.clamp(0, bytes.length);
  await truncated.writeAsBytes(bytes.sublist(0, end));
  return truncated;
}

Future<String> _transcribeWithFfmpeg(File videoFile, AIService aiService, Directory tempDir, int ts) async {
  final audioFile = File('${tempDir.path}/audio_$ts.mp3');
  final createdFiles = <File>[audioFile];

  try {
    final ffmpegResult = await Process.run('ffmpeg', [
      '-i', videoFile.path, '-vn', '-acodec', 'libmp3lame',
      '-ab', '64k', '-ar', '16000', '-ac', '1', '-y', audioFile.path,
    ]);

    if (ffmpegResult.exitCode != 0) {
      await _cleanupFiles(createdFiles);
      return await aiService.speechToText(videoFile);
    }

    final audioSizeMB = await audioFile.length() / (1024 * 1024);

    if (audioSizeMB <= 24) {
      final transcript = await aiService.speechToText(audioFile);
      await _cleanupFiles(createdFiles);
      return transcript;
    }

    final durationSec = await _getAudioDuration(audioFile.path);
    if (durationSec <= 0) {
      await _cleanupFiles(createdFiles);
      return await aiService.speechToText(videoFile);
    }

    final bytesPerSec = await audioFile.length() / durationSec;
    final maxChunkSec = (23 * 1024 * 1024 / bytesPerSec).floor();
    final chunkDuration = maxChunkSec.clamp(60, 600);

    final chunks = <File>[];
    var offset = 0;
    var idx = 0;

    while (offset < durationSec) {
      final chunkFile = File('${tempDir.path}/chunk_${ts}_$idx.mp3');
      createdFiles.add(chunkFile);
      chunks.add(chunkFile);

      final chunkResult = await Process.run('ffmpeg', [
        '-i', audioFile.path, '-ss', '$offset', '-t', '$chunkDuration',
        '-acodec', 'libmp3lame', '-ab', '64k', '-ar', '16000', '-ac', '1',
        '-y', chunkFile.path,
      ]);

      if (chunkResult.exitCode != 0) break;
      offset += chunkDuration;
      idx++;
    }

    final transcripts = <String>[];
    for (final chunk in chunks) {
      if (!await chunk.exists()) continue;
      final chunkSize = await chunk.length();
      if (chunkSize < 1000) continue;
      try {
        final text = await aiService.speechToText(chunk);
        if (text.isNotEmpty) transcripts.add(text);
      } catch (_) {}
    }

    await _cleanupFiles(createdFiles);
    return transcripts.join(' ');
  } catch (e) {
    await _cleanupFiles(createdFiles);
    rethrow;
  }
}

Future<void> _cleanupFiles(List<File> files) async {
  for (final f in files) {
    await _safeDelete(f);
  }
}

Future<void> _safeDelete(File f) async {
  try {
    if (await f.exists()) await f.delete();
  } catch (_) {}
}

Future<int> _getAudioDuration(String path) async {
  try {
    final result = await Process.run('ffprobe', [
      '-v', 'error', '-show_entries', 'format=duration', '-of', 'json', path,
    ]);
    if (result.exitCode == 0) {
      final data = jsonDecode(result.stdout as String);
      final dur = double.tryParse(data['format']?['duration']?.toString() ?? '') ?? 0;
      return dur.round();
    }
  } catch (_) {}
  return 0;
}
