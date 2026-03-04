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
  final rows = await db.select(db.semesters).get();
  return Response.json(
    body: {
      'semesters': rows
          .map((s) => {
                'id': s.id,
                'name': s.name,
                'year': s.year,
                'term': s.term,
                'startDate': s.startDate.toIso8601String(),
                'endDate': s.endDate.toIso8601String(),
                'isActive': s.isActive,
              })
          .toList(),
    },
  );
}

Future<Response> _create(RequestContext context, AppDatabase db) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final year = body['year'] as int?;
  final term = body['term'] as int?;
  final startDate = body['startDate'] as String?;
  final endDate = body['endDate'] as String?;

  if (name == null ||
      year == null ||
      term == null ||
      startDate == null ||
      endDate == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'name, year, term, startDate, endDate là bắt buộc'},
    );
  }

  try {
    final id = await db.into(db.semesters).insert(
          SemestersCompanion.insert(
            name: name,
            year: year,
            term: term,
            startDate: DateTime.parse(startDate),
            endDate: DateTime.parse(endDate),
            isActive: Value(body['isActive'] as bool? ?? false),
          ),
        );
    return Response.json(
      statusCode: 201,
      body: {'id': id, 'message': 'Tạo học kỳ thành công'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Lỗi tạo học kỳ: $e'},
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
    final stmt = db.update(db.semesters)..where((t) => t.id.equals(id));
    await stmt.write(SemestersCompanion(
      name: body['name'] != null
          ? Value(body['name'] as String)
          : const Value.absent(),
      year: body['year'] != null
          ? Value(body['year'] as int)
          : const Value.absent(),
      term: body['term'] != null
          ? Value(body['term'] as int)
          : const Value.absent(),
      startDate: body['startDate'] != null
          ? Value(DateTime.parse(body['startDate'] as String))
          : const Value.absent(),
      endDate: body['endDate'] != null
          ? Value(DateTime.parse(body['endDate'] as String))
          : const Value.absent(),
      isActive: body['isActive'] != null
          ? Value(body['isActive'] as bool)
          : const Value.absent(),
    ));
    return Response.json(body: {'message': 'Cập nhật học kỳ thành công'});
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
        await (db.delete(db.semesters)..where((t) => t.id.equals(id))).go();
    if (deleted == 0) {
      return Response.json(
          statusCode: 404, body: {'error': 'Không tìm thấy học kỳ'});
    }
    return Response.json(body: {'message': 'Xóa học kỳ thành công'});
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': 'Lỗi xóa: $e'});
  }
}
