import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final studentId = context.read<int>();
  final db = context.read<AppDatabase>();

  try {
    final body = await context.request.json();
    final code = body['code'] as String;

    final classInfo = await (db.select(db.classes)
      ..where((t) => t.classCode.equals(code)))
        .getSingleOrNull();

    if (classInfo == null) {
      return Response(statusCode: 404, body: 'Mã lớp không tồn tại');
    }

    final existing = await (db.select(db.schedules)
      ..where((t) =>
      t.userId.equals(studentId) & t.classId.equals(classInfo.id))
      ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      return Response(statusCode: 409, body: 'Bạn đã ở trong lớp này rồi');
    }


    final teacherSchedules = await (db.select(db.schedules)
      ..where((t) =>
      t.classId.equals(classInfo.id) &
      t.userId.equals(classInfo.teacherId)))
        .get();

    if (teacherSchedules.isEmpty) {
      return Response.json(
          body: {'message': 'Đã tham gia lớp, nhưng giáo viên chưa xếp lịch học.'});
    }

    await db.batch((batch) {
      for (final s in teacherSchedules) {
        batch.insert(
          db.schedules,
          SchedulesCompanion.insert(
            userId: studentId,
            classId: Value(classInfo.id),
            subjectName: s.subjectName,
            room: Value(s.room),
            startTime: s.startTime,
            endTime: s.endTime,
            note: Value(s.note),
            currentAbsences: const Value(0),
          ),
        );
      }
    });

    return Response.json(
        body: {'message': 'Đã tham gia lớp ${classInfo.className} thành công!'});

  } catch (e) {
    return Response(statusCode: 500, body: 'Lỗi server: $e');
  }
}