import 'dart:io';
import 'package:http/http.dart' as http;
class TranscriptionService {
  final String openaiApiKey;
  TranscriptionService({required this.openaiApiKey});
  Future<String> transcribeFile(File audioFile) async {
    const baseUrl = 'https://api.openai.com/v1/audio/transcriptions';
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $openaiApiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'vi';
      request.fields['response_format'] = 'text';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Whisper API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Transcription failed: $e');
    }
  }
  Future<String> transcribeFromUrl(String videoUrl) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp4');
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download media from URL');
      }
      await tempFile.writeAsBytes(response.bodyBytes);
      final fileSize = await tempFile.length();
      if (fileSize > 25 * 1024 * 1024) {
        await tempFile.delete();
        throw Exception('File too large for transcription (max 25MB)');
      }
      final transcript = await transcribeFile(tempFile);
      await tempFile.delete();
      return transcript;
    } catch (e) {
      throw Exception('Failed to transcribe from URL: $e');
    }
  }
  bool isTranscribableUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    if (host.contains('youtube') ||
        host.contains('youtu.be') ||
        host.contains('vimeo') ||
        host.contains('dailymotion') ||
        host.contains('tiktok') ||
        host.contains('facebook') ||
        host.contains('instagram')) {
      return false;
    }
    if (host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.')) {
      return true;
    }
    final path = uri.path.toLowerCase();
    if (path.endsWith('.mp4') ||
        path.endsWith('.mp3') ||
        path.endsWith('.m4a') ||
        path.endsWith('.wav') ||
        path.endsWith('.webm') ||
        path.endsWith('.mpeg') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi')) {
      return true;
    }
    if (path.contains('/uploads/') ||
        path.contains('/videos/') ||
        path.contains('/media/')) {
      return true;
    }
    return true;
  }
}
