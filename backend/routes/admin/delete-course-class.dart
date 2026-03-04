import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final idStr = context.request.uri.queryParameters['id'];
  final ccId = int.tryParse(idStr ?? '');
  if (ccId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'id (course class ID) is required'},
    );
  }

  try {
    final db = context.read<AppDatabase>();

    final existing = await (db.select(db.courseClasses)
          ..where((c) => c.id.equals(ccId)))
        .getSingleOrNull();
    if (existing == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Không tìm thấy lớp'},
      );
    }

    final deletedEnrollments = await (db.delete(db.courseClassEnrollments)
          ..where((e) => e.courseClassId.equals(ccId)))
        .go();

    await (db.delete(db.courseClasses)..where((c) => c.id.equals(ccId))).go();

    return Response.json(body: {
      'success': true,
      'message':
          'Đã xóa lớp ${existing.classCode} và $deletedEnrollments ghi danh.',
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Lỗi: $e'},
    );
  }
}
