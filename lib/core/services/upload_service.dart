import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_constants.dart';

class UploadService {
  final SharedPreferences _prefs;

  UploadService(this._prefs);

  String? get _token => _prefs.getString('token');

  Future<Map<String, dynamic>> uploadFileBytes(
    Uint8List fileBytes,
    String fileName, {
    int? lessonId,
    String fileType = 'document',
  }) async {
    final userId = _prefs.getInt('userId');
    if (userId == null) throw Exception('User not authenticated');

    final uri = Uri.parse('${ApiConstants.baseUrl}/upload');
    final request = http.MultipartRequest('POST', uri);

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.fields['uploadedBy'] = userId.toString();
    request.fields['fileType'] = fileType;
    if (lessonId != null) {
      request.fields['lessonId'] = lessonId.toString();
    }

    final ext = fileName.split('.').last.toLowerCase();
    const mimeMap = {
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
      'webm': 'video/webm',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'zip': 'application/zip',
      'rar': 'application/x-rar-compressed',
      'txt': 'text/plain',
    };
    final mime = mimeMap[ext] ?? 'application/octet-stream';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mime),
    ));

    final streamed = await request.send().timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        throw TimeoutException('Upload timed out after 10 minutes');
      },
    );
    final responseBody = await streamed.stream.bytesToString();

    if (streamed.statusCode == 201) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(responseBody) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Upload failed');
    }
  }

  Future<void> deleteFile(int fileId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/files/$fileId');
    final response = await http.delete(
      uri,
      headers: {if (_token != null) 'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete file');
    }
  }
}
