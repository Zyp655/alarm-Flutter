import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_constants.dart';

class ContentAnalyzerService {
  Future<ContentStructureResult> analyzeContent({
    required String fileName,
    required String fileType,
    String? content,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${ApiConstants.baseUrl}/content/analyze');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fileName': fileName,
          'fileType': fileType,
          'content': content ?? fileName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ContentStructureResult.success(data);
      } else {
        return ContentStructureResult.failure(
          'Lỗi phân tích: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ContentStructureResult.failure('Lỗi: $e');
    }
  }

  Future<Map<String, dynamic>?> generateQuizForModule({
    required int moduleId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/modules/$moduleId/quiz/generate',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error generating quiz: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveQuizForModule({
    required int moduleId,
    required List<Map<String, dynamic>> questions,
    String topic = 'Quiz',
    String difficulty = 'medium',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${ApiConstants.baseUrl}/modules/$moduleId/quiz');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'questions': questions,
          'topic': topic,
          'difficulty': difficulty,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error saving quiz: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSavedQuiz({required int moduleId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${ApiConstants.baseUrl}/modules/$moduleId/quiz');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error getting quiz: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}

class ContentStructureResult {
  final bool isSuccess;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  ContentStructureResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory ContentStructureResult.success(Map<String, dynamic> data) {
    return ContentStructureResult._(isSuccess: true, data: data);
  }

  factory ContentStructureResult.failure(String message) {
    return ContentStructureResult._(isSuccess: false, errorMessage: message);
  }

  List<SuggestedModule> get suggestedModules {
    if (data == null) return [];
    final modules = data!['suggestedModules'] as List<dynamic>? ?? [];
    return modules.map((m) => SuggestedModule.fromJson(m)).toList();
  }

  String? get summary => data?['summary'] as String?;
  int? get totalDuration => data?['totalEstimatedDuration'] as int?;
}

class SuggestedModule {
  final String title;
  final String? description;
  final List<SuggestedLesson> lessons;

  SuggestedModule({
    required this.title,
    this.description,
    required this.lessons,
  });

  factory SuggestedModule.fromJson(Map<String, dynamic> json) {
    final lessonsList = json['lessons'] as List<dynamic>? ?? [];
    return SuggestedModule(
      title: json['title'] as String? ?? 'Chương không tên',
      description: json['description'] as String?,
      lessons: lessonsList.map((l) => SuggestedLesson.fromJson(l)).toList(),
    );
  }
}

class SuggestedLesson {
  final String title;
  final String? description;
  final int estimatedDuration;

  SuggestedLesson({
    required this.title,
    this.description,
    this.estimatedDuration = 10,
  });

  factory SuggestedLesson.fromJson(Map<String, dynamic> json) {
    return SuggestedLesson(
      title:
          json['title'] as String? ??
          json['suggestedTitle'] as String? ??
          'Bài học không tên',
      description: json['description'] as String?,
      estimatedDuration: json['estimatedDuration'] as int? ?? 10,
    );
  }
}
