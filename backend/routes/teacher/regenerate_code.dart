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
    final subjectName = body['subjectName'] as String;
    final bool forceRefresh = (body['forceRefresh'] as bool?) ?? false;

    var existingClass = await (db.select(db.classes)
          ..where((t) =>
              t.className.equals(subjectName) & t.teacherId.equals(teacherId))
          ..limit(1))
        .getSingleOrNull();

    int classId;
    String codeToReturn;

    if (existingClass == null) {
      codeToReturn = generateClassCode();

      classId = await db.into(db.classes).insert(ClassesCompanion.insert(
            className: subjectName,
            classCode: codeToReturn,
            teacherId: teacherId,
            createdAt: DateTime.now(),
          ));
    } else {
      classId = existingClass.id;

      if (!forceRefresh && existingClass.classCode.isNotEmpty) {
        codeToReturn = existingClass.classCode;
      } else {
        codeToReturn = generateClassCode();
        await (db.update(db.classes)..where((t) => t.id.equals(classId)))
            .write(ClassesCompanion(classCode: Value(codeToReturn)));
      }
    }

    await (db.update(db.schedules)
          ..where((t) =>
              t.subjectName.equals(subjectName) & t.userId.equals(teacherId)))
        .write(SchedulesCompanion(classId: Value(classId)));

    return Response.json(body: {'newCode': codeToReturn});
  } catch (e) {
    return Response(statusCode: 500, body: 'Lỗi server: $e');
  }
}
