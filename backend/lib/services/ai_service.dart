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
  Future<Map<String, dynamic>> generateQuizFromContext({
    required String context,
    required String moduleTitle,
    int numQuestions = 5,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';
    final prompt = '''
Bạn là chuyên gia giáo dục và đánh giá năng lực.
Nhiệm vụ: Tạo bài kiểm tra trắc nghiệm cho chương "$moduleTitle" dựa trên nội dung được cung cấp bên dưới.
Yêu cầu dữ liệu ("Source of Truth"):
- CHỈ sử dụng thông tin có trong nội dung cung cấp.
- KHÔNG tạo câu hỏi chung chung hoặc bề mặt.
- Tập trung vào các khái niệm then chốt, case study, và các lỗi thường gặp được đề cập.
Nội dung bài học:
"""
$context
"""
Hãy tạo $numQuestions câu hỏi trắc nghiệm.
Mỗi câu hỏi cần có:
1. Nội dung sâu sắc, kiểm tra khả năng hiểu và vận dụng.
2. 4 đáp án lựa chọn.
3. Giải thích chi tiết (Feedback) tại sao đáp án đó đúng, trích dẫn ý từ nội dung.
Trả về JSON format:
{
  "questions": [
    {
      "question": "Nội dung câu hỏi...",
      "options": ["A", "B", "C", "D"],
      "correctIndex": 0,
      "explanation": "Giải thích chi tiết..."
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
                'You are an advanced quiz generator. Always respond with valid JSON only.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.5,
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
  Future<String> generateNudgeMessage({
    required String studentName,
    required String courseName,
    required int daysInactive,
    required int progressPercent,
    String? nextLessonTitle,
    String? nextLessonDeepLink,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';
    final prompt = '''
Bạn là trợ lý học tập AI thân thiện. Hãy viết một tin nhắn ngắn (dưới 50 từ) để nhắc nhở học viên quay lại học.
Thông tin học viên:
- Tên: $studentName
- Khóa học: $courseName
- Số ngày vắng mặt: $daysInactive ngày
- Tiến độ: $progressPercent%
- Bài học tiếp theo: ${nextLessonTitle ?? "Chưa xác định"}
Yêu cầu:
1. Giọng văn: Thân thiện, khích lệ, không trách móc.
2. Nếu vắng < 5 ngày: Nhấn mạnh vào việc hoàn thành mục tiêu (tiến độ đang dở dang).
3. Nếu vắng >= 5 ngày: Nhấn mạnh vào nội dung thú vị đang chờ đợi hoặc cộng đồng lớp học.
4. Cuối tin nhắn, hãy chèn link bài học này để họ bấm vào học ngay: ${nextLessonDeepLink ?? ""}
   (Format link: [Tiếp tục học ngay]($nextLessonDeepLink))
Ví dụ output mong muốn:
"Chào Nam 👋, bạn đã đi được 80% chặng đường khóa Flutter rồi! Đừng để kiến thức nguội lạnh nhé. Bài học 'State Management' đang chờ cậu đó. 👉 [Tiếp tục học ngay](link)"
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
            'content': 'You are a helpful learning assistant.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 150,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception(
          'OpenAI API Error: ${response.statusCode} - ${response.body}');
    }
  }
  Future<Map<String, dynamic>> generateEngagementReport({
    required String courseName,
    required List<Map<String, dynamic>> moduleStats,
    required int totalStudents,
  }) async {
    const baseUrl = 'https://api.openai.com/v1/chat/completions';
    final statsJson = jsonEncode(moduleStats);
    final prompt = '''
Bạn là một Data Scientist & Chuyên gia Sư phạm. Hãy phân tích dữ liệu khóa học "$courseName" ($totalStudents học viên) dưới đây và tìm ra nguyên nhân học viên bỏ học.
Dữ liệu từng chương (Module Data):
$statsJson
Yêu cầu phân tích:
1. Xác định "Top Bottleneck" (Điểm nghẽn lớn nhất): Chương nào có tỷ lệ hoàn thành tụt giảm mạnh nhất so với chương trước? Hoặc điểm Quiz thấp nhất?
2. Tìm mối tương quan: Có phải điểm Quiz thấp dẫn đến việc bỏ học ở chương sau không?
3. Đưa ra 03 nguyên nhân chính khiến sinh viên bỏ cuộc.
4. Đề xuất 03 giải pháp sư phạm cụ thể để cải thiện.
Trả về kết quả dạng JSON (KHÔNG Markdown):
{
  "summary": "Tóm tắt ngắn gọn về tình hình (ví dụ: Tỷ lệ rơi rớt tập trung ở Module 3 do kiến thức quá khó...)",
  "top_bottleneck": {
    "moduleName": "Tên chương",
    "dropRate": 0.45,
    "avgScore": 4.5
  },
  "causes": ["Nguyên nhân 1", "Nguyên nhân 2", "Nguyên nhân 3"],
  "recommendations": ["Giải pháp 1", "Giải pháp 2", "Giải pháp 3"]
}
''';
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an expert Educational Data Scientist. Always respond with valid JSON.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.5,
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
