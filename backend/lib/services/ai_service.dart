import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String openaiApiKey;

  AIService({required this.openaiApiKey});

  Future<Map<String, dynamic>> generateQuiz({
    required String topic,
    required int numQuestions,
    required String difficulty,
    String? subjectContext,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';

    final prompt =
        _buildPrompt(topic, numQuestions, difficulty, subjectContext);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini', 
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a quiz generator. Always respond with valid JSON only, no markdown.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2048, 
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      final jsonStr = _extractJson(text);
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } else {
      throw Exception(
          'OpenAI API Error: ${response.statusCode} - ${response.body}');
    }
  }

  String _buildPrompt(String topic, int numQuestions, String difficulty,
      String? subjectContext) {
    final difficultyVi = {
      'easy': 'dễ',
      'medium': 'trung bình',
      'hard': 'khó',
    };

    return '''
Tạo một bài quiz trắc nghiệm về chủ đề "$topic" với $numQuestions câu hỏi ở mức độ ${difficultyVi[difficulty] ?? difficulty}.
${subjectContext != null ? 'Ngữ cảnh môn học: $subjectContext' : ''}

Trả về KẾT QUẢ DẠNG JSON với format sau (KHÔNG có markdown, CHỈ JSON thuần):
{
  "topic": "$topic",
  "difficulty": "$difficulty",
  "questions": [
    {
      "question": "Nội dung câu hỏi?",
      "options": ["Đáp án A", "Đáp án B", "Đáp án C", "Đáp án D"],
      "correctIndex": 0,
      "explanation": "Giải thích tại sao đáp án đúng"
    }
  ]
}

Lưu ý:
- correctIndex là chỉ số của đáp án đúng (0-3)
- Mỗi câu có đúng 4 đáp án
- Câu hỏi phải chính xác và phù hợp với độ khó
- CHỈ TRẢ VỀ JSON, KHÔNG CÓ TEXT KHÁC
''';
  }

  String _extractJson(String text) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!;
    }
    return text;
  }
}
