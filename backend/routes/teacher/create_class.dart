import 'dart:math';

import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';

String _generateClassCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rnd = Random();
  return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;
  final className = body['className'] as String?;
  final teacherId = body['teacherId'] as int?;

  if (className == null || teacherId == null) {
    return Response(statusCode: 400, body: 'Thiếu thông tin');
  }

  final code = _generateClassCode();

  await db.into(db.classes).insert(ClassesCompanion.insert(
      className: className,
      classCode: code,
      teacherId: teacherId,
      createdAt: DateTime.now(),
  ));

  return Response.json(body: {
    'message': 'Tạo lớp thành công',
    'classCode': code,
    'className': className
  });
}
