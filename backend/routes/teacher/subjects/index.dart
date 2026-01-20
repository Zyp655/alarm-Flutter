import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  final db = context.read<AppDatabase>();

  if (method == HttpMethod.get) {
    final params = context.request.uri.queryParameters;
    if (!params.containsKey('teacherId')) {
      return Response(statusCode: 400, body: 'Missing teacherId');
    }
    final teacherId = int.parse(params['teacherId']!);

    final subjects = await (db.select(db.subjects)
          ..where((s) => s.teacherId.equals(teacherId)))
        .get();

    final list = subjects
        .map((s) => {
              'id': s.id,
              'name': s.name,
              'code': s.code,
              'credits': s.credits,
            })
        .toList();

    return Response.json(body: list);
  }

  if (method == HttpMethod.post) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      final teacherId = body['teacherId'] as int;
      final name = body['name'] as String;
      final credits = body['credits'] as int? ?? 3;
      final code = body['code'] as String?;

      final id = await db.into(db.subjects).insert(SubjectsCompanion.insert(
            teacherId: teacherId,
            name: name,
            credits: Value(credits),
            code: Value(code),
          ));

      return Response.json(body: {'message': 'Tạo môn thành công', 'id': id});
    } catch (e) {
      return Response(statusCode: 500, body: 'Lỗi server: $e');
    }
  }

  return Response(statusCode: 405);
}
