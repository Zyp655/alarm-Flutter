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
              t.userId.equals(studentId) & t.classId.equals(classInfo.id)))
        .getSingleOrNull();

    if (existing != null) {
      return Response(statusCode: 409, body: 'Bạn đã ở trong lớp này rồi');
    }

    await db.into(db.schedules).insert(SchedulesCompanion.insert(
          userId: studentId,
          classId: Value(classInfo.id),
          subjectName: classInfo.className,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          room: const Value('Online'),
        ));

    return Response.json(
        body: {'message': 'Đã tham gia lớp ${classInfo.className}'});
  } catch (e) {
    return Response(statusCode: 500, body: 'Lỗi: $e');
  }
}
