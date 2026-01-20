import 'package:backend/database/database.dart';
import 'package:backend/utils/code_generator.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();

  try {
    final body = await context.request.json();
    final teacherId = body['teacherId'] as int;
    final schedules = body['schedules'] as List;

    int newClassesCreated = 0;
    int schedulesAdded = 0;

    for (var element in schedules) {
      final item = element as Map<String, dynamic>;

      final subjectName = item['subject'] as String;
      final room = item['room'] as String?;
      final start = DateTime.parse(item['start'] as String);
      final end = DateTime.parse(item['end'] as String);

      final credits = item['credits'] as int? ?? 3;
      final maxAbsences = credits * 3;

      int classId;

      final existingClass = await (db.select(db.classes)
        ..where((t) =>
        t.className.equals(subjectName) & t.teacherId.equals(teacherId))
        ..limit(1))
          .getSingleOrNull();

      if (existingClass != null) {
        classId = existingClass.id;
      } else {
        final newCode = generateClassCode();

        classId = await db.into(db.classes).insert(ClassesCompanion.insert(
          className: subjectName,
          classCode: newCode,
          teacherId: teacherId,
          createdAt: DateTime.now(),
        ));
        newClassesCreated++;
      }

      await db.into(db.schedules).insert(SchedulesCompanion.insert(
        userId: teacherId,
        classId: Value(classId),
        subjectName: subjectName,
        startTime: start,
        endTime: end,
        room: Value(room),
        credits: Value(credits),
        maxAbsences: Value(maxAbsences),
      ));
      schedulesAdded++;
    }

    return Response.json(body: {
      'message': 'Thành công',
      'schedulesAdded': schedulesAdded,
      'newClassesCreated': newClassesCreated,
    });
  } catch (e) {
    print("Lỗi Import: $e");
    return Response(statusCode: 500, body: 'Lỗi server: $e');
  }
}