import 'dart:convert';
import 'package:http/http.dart' as http;
class GeminiService {
  final String apiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';
  GeminiService({required this.apiKey});
  Future<Map<String, dynamic>> generateQuiz({
    required String topic,
    required int numQuestions,
    required String difficulty,
    String? subjectContext,
  }) async {
    final difficultyVi = _getDifficultyInVietnamese(difficulty);
    final prompt = '''
Bạn là một giáo viên chuyên nghiệp. Hãy tạo một bài quiz trắc nghiệm với các thông tin sau:
- Chủ đề: $topic
${subjectContext != null ? '- Ngữ cảnh môn học: $subjectContext' : ''}
- Số câu hỏi: $numQuestions
- Độ khó: $difficultyVi
Yêu cầu:
1. Mỗi câu hỏi có 4 đáp án (A, B, C, D)
2. Chỉ có 1 đáp án đúng
3. Cung cấp giải thích ngắn gọn cho đáp án đúng
4. Câu hỏi phải rõ ràng, không mơ hồ
Trả lời theo định dạng JSON CHÍNH XÁC như sau (không có text khác):
{
  "topic": "$topic",
  "difficulty": "$difficulty",
  "questions": [
    {
      "question": "Nội dung câu hỏi?",
      "options": ["Đáp án A", "Đáp án B", "Đáp án C", "Đáp án D"],
      "correctIndex": 0,
      "explanation": "Giải thích tại sao đáp án A đúng"
    }
  ]
}
Chú ý: correctIndex là số từ 0-3 tương ứng với vị trí đáp án đúng trong mảng options.
''';
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final jsonStr = _extractJson(text);
        final quizData = jsonDecode(jsonStr) as Map<String, dynamic>;
        return quizData;
      } else {
        throw Exception(
            'Gemini API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }
  String _getDifficultyInVietnamese(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Dễ (câu hỏi cơ bản, dễ hiểu)';
      case 'medium':
        return 'Trung bình (câu hỏi yêu cầu hiểu biết tốt)';
      case 'hard':
        return 'Khó (câu hỏi nâng cao, cần suy luận)';
      default:
        return 'Trung bình';
    }
  }
  String _extractJson(String text) {
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
      throw Exception('Invalid JSON response from Gemini');
    }
    return text.substring(jsonStart, jsonEnd + 1);
  }
}
