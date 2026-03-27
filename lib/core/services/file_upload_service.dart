import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_constants.dart';

class FileUploadService {
  Future<FileUploadResult> uploadFileBytes({
    required Uint8List fileBytes,
    required String fileName,
    required String fileType,
    int? lessonId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final token = prefs.getString('token');

      if (userId == null) {
        return FileUploadResult.failure('User not logged in');
      }

      final maxSize = fileType == 'video'
          ? 500 * 1024 * 1024
          : 50 * 1024 * 1024;
      if (fileBytes.length > maxSize) {
        final maxMB = maxSize ~/ (1024 * 1024);
        return FileUploadResult.failure('File quá lớn. Tối đa ${maxMB}MB');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/upload');
      final request = http.MultipartRequest('POST', url);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['uploadedBy'] = userId.toString();
      request.fields['fileType'] = fileType;
      if (lessonId != null) {
        request.fields['lessonId'] = lessonId.toString();
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(_mimeType(fileName, fileType)),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final body = response.body;
        final uploadUrlMatch = RegExp(
          r'"uploadUrl":"([^"]+)"',
        ).firstMatch(body);
        final uploadUrl = uploadUrlMatch?.group(1) ?? '';
        return FileUploadResult.success(uploadUrl);
      } else {
        return FileUploadResult.failure(
          'Upload thất bại: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FileUploadResult.failure('Lỗi upload: $e');
    }
  }

  String _mimeType(String fileName, String fileType) {
    final ext = fileName.split('.').last.toLowerCase();
    const mimeMap = {
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
      'webm': 'video/webm',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return mimeMap[ext] ?? (fileType == 'video' ? 'video/mp4' : 'application/octet-stream');
  }

  List<String> getAllowedExtensions(String fileType) {
    if (fileType == 'video') {
      return ['mp4', 'mov', 'avi', 'webm'];
    } else {
      return ['pdf', 'doc', 'docx'];
    }
  }
}

class FileUploadResult {
  final bool isSuccess;
  final String? uploadUrl;
  final String? errorMessage;

  FileUploadResult._({
    required this.isSuccess,
    this.uploadUrl,
    this.errorMessage,
  });

  factory FileUploadResult.success(String url) {
    return FileUploadResult._(isSuccess: true, uploadUrl: url);
  }

  factory FileUploadResult.failure(String message) {
    return FileUploadResult._(isSuccess: false, errorMessage: message);
  }
}
