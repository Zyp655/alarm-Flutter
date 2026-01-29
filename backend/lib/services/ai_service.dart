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
    String? videoUrl,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';

    final prompt =
        _buildPrompt(topic, numQuestions, difficulty, subjectContext, videoUrl);

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
      String? subjectContext, String? videoUrl) {
    final difficultyVi = {
      'easy': 'dễ',
      'medium': 'trung bình',
      'hard': 'khó',
    };

    String videoContext = '';
    if (videoUrl != null && videoUrl.isNotEmpty) {
      videoContext = '''
Đây là quiz dựa trên nội dung video bài học từ URL: $videoUrl
Hãy tạo câu hỏi liên quan đến chủ đề "$topic" phù hợp với nội dung có thể có trong video này.
''';
    }

    return '''
Tạo một bài quiz trắc nghiệm về chủ đề "$topic" với $numQuestions câu hỏi ở mức độ ${difficultyVi[difficulty] ?? difficulty}.
${subjectContext != null ? 'Ngữ cảnh môn học: $subjectContext' : ''}
$videoContext

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

  /// Phân tích nội dung file và gợi ý cấu trúc module/lesson
  /// [content] - Nội dung text trích xuất từ file (PDF text, mục lục, etc.)
  /// [fileName] - Tên file để AI hiểu ngữ cảnh
  /// [fileType] - 'video' hoặc 'document'
  Future<Map<String, dynamic>> analyzeContentStructure({
    required String content,
    required String fileName,
    required String fileType,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';

    final prompt = '''
Bạn là một chuyên gia thiết kế khóa học. Phân tích nội dung sau và đề xuất cách chia thành các chương (modules) và bài học (lessons).

Tên file: $fileName
Loại file: $fileType
Nội dung:
$content

Hãy phân tích và trả về cấu trúc khóa học gợi ý theo định dạng JSON sau:
{
  "suggestedModules": [
    {
      "title": "Tên chương",
      "description": "Mô tả ngắn về chương này",
      "lessons": [
        {
          "title": "Tên bài học",
          "description": "Mô tả ngắn",
          "estimatedDuration": 10
        }
      ]
    }
  ],
  "totalEstimatedDuration": 60,
  "summary": "Tóm tắt ngắn về nội dung"
}

Lưu ý:
- Chia hợp lý dựa trên nội dung thực tế
- Mỗi chương nên có 2-5 bài học
- estimatedDuration tính bằng phút
- CHỈ TRẢ VỀ JSON, KHÔNG CÓ TEXT KHÁC
''';

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
                'You are a course structure analyzer. Always respond with valid JSON only, no markdown.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 4096,
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

  /// Phân tích nhiều file và gợi ý cách gom nhóm thành chương
  Future<Map<String, dynamic>> analyzeMultipleFiles({
    required List<Map<String, String>> files,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';

    final fileList =
        files.map((f) => '- ${f['fileName']} (${f['fileType']})').join('\n');

    final prompt = '''
Bạn có danh sách các file sau:
$fileList

Hãy gợi ý cách gom nhóm các file này thành các chương (modules) và bài học (lessons) hợp lý.

Trả về JSON:
{
  "suggestedModules": [
    {
      "title": "Tên chương",
      "lessons": [
        {"fileName": "tên_file.pdf", "suggestedTitle": "Tên bài học gợi ý"}
      ]
    }
  ]
}

CHỈ TRẢ VỀ JSON.
''';

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
                'You are a course organizer. Respond with valid JSON only.'
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
}
