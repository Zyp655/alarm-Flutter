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

    final existingClass = await (db.select(db.classes)
          ..where((t) =>
              t.className.equals(subjectName) & t.teacherId.equals(teacherId))
          ..limit(1))
        .getSingleOrNull();

    if (existingClass == null) {
      return Response(statusCode: 404, body: 'Không tìm thấy lớp học');
    }

    if (!forceRefresh &&
        existingClass.classCode != null &&
        existingClass.classCode!.isNotEmpty) {
      return Response.json(body: {'newCode': existingClass.classCode});
    }

    // 3. Tạo mới
    final newCode = generateClassCode();

    await (db.update(db.classes)..where((t) => t.id.equals(existingClass.id)))
        .write(ClassesCompanion(classCode: Value(newCode)));

    return Response.json(body: {'newCode': newCode});
  } catch (e) {
    return Response(statusCode: 500, body: 'Lỗi: $e');
  }
}
