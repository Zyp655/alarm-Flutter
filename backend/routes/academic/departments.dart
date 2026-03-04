import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getAll(db);
    case HttpMethod.post:
      return _create(context, db);
    case HttpMethod.put:
      return _update(context, db);
    case HttpMethod.delete:
      return _delete(context, db);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getAll(AppDatabase db) async {
  final rows = await db.select(db.departments).get();
  return Response.json(
    body: {
      'departments': rows
          .map((d) => {
                'id': d.id,
                'name': d.name,
                'code': d.code,
                'description': d.description,
                'createdAt': d.createdAt.toIso8601String(),
              })
          .toList(),
    },
  );
}

Future<Response> _create(RequestContext context, AppDatabase db) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final code = body['code'] as String?;

  if (name == null || code == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name và code là bắt buộc'},
    );
  }

  try {
    final id = await db.into(db.departments).insert(
          DepartmentsCompanion.insert(
            name: name,
            code: code,
            description: Value(body['description'] as String?),
            createdAt: DateTime.now(),
          ),
        );
    return Response.json(
      statusCode: 201,
      body: {'id': id, 'message': 'Tạo khoa thành công'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 409,
      body: {'error': 'Mã khoa đã tồn tại hoặc lỗi: $e'},
    );
  }
}

Future<Response> _update(RequestContext context, AppDatabase db) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final id = body['id'] as int?;
  if (id == null) {
    return Response.json(statusCode: 400, body: {'error': 'id là bắt buộc'});
  }

  try {
    final stmt = db.update(db.departments)..where((t) => t.id.equals(id));
    await stmt.write(DepartmentsCompanion(
      name: body['name'] != null
          ? Value(body['name'] as String)
          : const Value.absent(),
      code: body['code'] != null
          ? Value(body['code'] as String)
          : const Value.absent(),
      description: body.containsKey('description')
          ? Value(body['description'] as String?)
          : const Value.absent(),
    ));
    return Response.json(body: {'message': 'Cập nhật khoa thành công'});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Lỗi cập nhật: $e'});
  }
}

Future<Response> _delete(RequestContext context, AppDatabase db) async {
  final idStr = context.request.uri.queryParameters['id'];
  final id = int.tryParse(idStr ?? '');
  if (id == null) {
    return Response.json(statusCode: 400, body: {'error': 'id là bắt buộc'});
  }

  try {
    final deleted =
        await (db.delete(db.departments)..where((t) => t.id.equals(id))).go();
    if (deleted == 0) {
      return Response.json(
          statusCode: 404, body: {'error': 'Không tìm thấy khoa'});
    }
    return Response.json(body: {'message': 'Xóa khoa thành công'});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Lỗi xóa: $e'});
  }
}
