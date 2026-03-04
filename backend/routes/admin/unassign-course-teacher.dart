import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final courseClassId = body['courseClassId'] as int?;
    if (courseClassId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({
          'success': false,
          'error': 'courseClassId is required',
        }),
      );
    }

    final existing = await (db.select(db.courseClasses)
          ..where((cc) => cc.id.equals(courseClassId)))
        .getSingleOrNull();
    if (existing == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'success': false, 'error': 'Class not found'}),
      );
    }

    await (db.update(db.courseClasses)
          ..where((cc) => cc.id.equals(courseClassId)))
        .write(const CourseClassesCompanion(teacherId: Value(null)));

    return Response.json(
      body: {
        'success': true,
        'message': 'Đã bỏ phân công GV khỏi lớp ${existing.classCode}',
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': '$e'}),
    );
  }
}
