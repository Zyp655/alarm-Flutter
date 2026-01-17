import 'package:backend/repositories/student_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final scheduleId = int.tryParse(id);
  if (scheduleId == null) {
    return Response(statusCode: 400, body: 'ID không hợp lệ');
  }

  final userId = context.read<int>();
  final repo = context.read<StudentRepository>();

  if (context.request.method == HttpMethod.delete) {
    final rowsAffected = await repo.deleteSchedule(userId, scheduleId);

    if (rowsAffected > 0) {
      return Response.json(body: {'message': 'Đã xóa thành công'});
    } else {
      return Response(
          statusCode: 404,
          body: 'Không tìm thấy lịch học hoặc bạn không có quyền xóa');
    }
  }

  if (context.request.method == HttpMethod.put) {
    try {
      final json = await context.request.json() as Map<String, dynamic>;

      final success = await repo.updateSchedule(
        userId: userId,
        scheduleId: scheduleId,
        subject: json['subject'] as String,
        room: json['room'] as String? ?? '',
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        note: json['note'] as String?,
        imagePath: json['imagePath'] as String?,
        currentAbsences: json['currentAbsences'] as int?,
        maxAbsences: json['maxAbsences'] as int?,
      );

      if (success) {
        return Response.json(body: {'message': 'Cập nhật thành công'});
      } else {
        return Response(statusCode: 404, body: 'Không tìm thấy lịch để sửa');
      }
    } catch (e) {
      return Response(statusCode: 400, body: 'Dữ liệu không hợp lệ: $e');
    }
  }

  return Response(statusCode: 405);
}
