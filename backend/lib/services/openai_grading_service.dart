import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIGradingService {
  static final String _apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';

  static Future<Map<String, dynamic>> gradeSubmission({
    required String assignmentTitle,
    required String assignmentDescription,
    required String studentSubmission,
  }) async {
    if (_apiKey.isEmpty) {
      return {
        'score': 0,
        'feedback': 'Lỗi: Chưa cấu hình OPENAI_API_KEY',
        'suggestions': 'Vui lòng thêm OPENAI_API_KEY vào file .env',
      };
    }

    final prompt = '''
Bạn là giáo viên chấm bài tập. Hãy đánh giá bài làm của sinh viên dựa trên yêu cầu bài tập.

**Yêu cầu bài tập:**
Tiêu đề: $assignmentTitle
Mô tả: $assignmentDescription

**Bài làm của sinh viên:**
$studentSubmission

Hãy trả lời theo cấu trúc JSON:
{
  "score": <điểm từ 0.0 đến 10.0>,
  "feedback": "<nhận xét chi tiết về bài làm>",
  "suggestions": "<hướng cải thiện cụ thể>"
}

Chỉ trả về JSON, không có text nào khác.
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Bạn là một giáo viên chuyên nghiệp, chấm bài tập sinh viên. Luôn trả lời bằng tiếng Việt và chỉ trả về JSON.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        final jsonStr =
            content.replaceAll('```json', '').replaceAll('```', '').trim();

        final result = jsonDecode(jsonStr) as Map<String, dynamic>;

        return {
          'score': (result['score'] as num?)?.toDouble() ?? 0.0,
          'feedback': result['feedback'] ?? 'Không có nhận xét',
          'suggestions': result['suggestions'] ?? 'Không có đề xuất',
        };
      } else {
        return {
          'score': 0,
          'feedback': 'Lỗi API: ${response.statusCode}',
          'suggestions': 'Vui lòng thử lại sau',
        };
      }
    } catch (e) {
      return {
        'score': 0,
        'feedback': 'Lỗi kết nối: $e',
        'suggestions': 'Kiểm tra kết nối mạng và API key',
      };
    }
  }
}
