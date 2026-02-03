import 'package:backend/database/database.dart';
import 'package:backend/repositories/student_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final scheduleId = int.tryParse(id);
  if (scheduleId == null) {
    return Response(statusCode: 400, body: 'ID không hợp lệ');
  }
  final userId = context.read<int>();
  final db = context.read<AppDatabase>();
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
      final currentSchedule = await (db.select(db.schedules)
            ..where((t) => t.id.equals(scheduleId) & t.userId.equals(userId)))
          .getSingleOrNull();
      if (currentSchedule == null) {
        return Response(statusCode: 404, body: 'Không tìm thấy lịch để sửa');
      }
      if (currentSchedule.classId != null) {
        await (db.update(db.schedules)
              ..where((t) =>
                  t.classId.equals(currentSchedule.classId!) &
                  t.userId.equals(userId)))
            .write(SchedulesCompanion(
          midtermScore: Value((json['midtermScore'] as num?)?.toDouble()),
          finalScore: Value((json['finalScore'] as num?)?.toDouble()),
          currentAbsences: Value(json['currentAbsences'] as int? ?? 0),
          maxAbsences: Value(json['maxAbsences'] as int? ?? 3),
          note: Value(json['note'] as String?),
        ));
      } else {
        await repo.updateSchedule(
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
          type: json['type'] as String?,
          format: json['format'] as String?,
        );
      }
      return Response.json(body: {'message': 'Cập nhật thành công'});
    } catch (e) {
      return Response(statusCode: 400, body: 'Dữ liệu không hợp lệ: $e');
    }
  }
  return Response(statusCode: 405);
}