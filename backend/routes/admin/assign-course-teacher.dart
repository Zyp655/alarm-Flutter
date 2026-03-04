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
    final teacherId = body['teacherId'] as int?;
    final force = body['force'] as bool? ?? false;

    if (courseClassId == null || teacherId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({
          'success': false,
          'error': 'courseClassId and teacherId are required',
        }),
      );
    }

    final cc = await (db.select(db.courseClasses)
          ..where((c) => c.id.equals(courseClassId)))
        .getSingleOrNull();
    if (cc == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'success': false, 'error': 'Class not found'}),
      );
    }

    final teacher = await (db.select(db.users)
          ..where((u) => u.id.equals(teacherId) & u.role.equals(1)))
        .getSingleOrNull();
    if (teacher == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'success': false, 'error': 'Teacher not found'}),
      );
    }

    if (cc.teacherId != null && cc.teacherId != teacherId && !force) {
      final currentTeacher = await (db.select(db.users)
            ..where((u) => u.id.equals(cc.teacherId!)))
          .getSingleOrNull();
      return Response.json(
        body: {
          'success': false,
          'needConfirm': true,
          'message':
              'Lớp ${cc.classCode} đã có GV ${currentTeacher?.fullName ?? "Unknown"}. Bạn muốn thay thế?',
          'currentTeacher': {
            'id': currentTeacher?.id,
            'name': currentTeacher?.fullName ?? currentTeacher?.email ?? '',
          },
        },
      );
    }

    await (db.update(db.courseClasses)
          ..where((c) => c.id.equals(courseClassId)))
        .write(CourseClassesCompanion(teacherId: Value(teacherId)));

    final teacherName = teacher.fullName ?? teacher.email;

    return Response.json(
      body: {
        'success': true,
        'message': 'Đã phân công $teacherName phụ trách lớp ${cc.classCode}',
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': '$e'}),
    );
  }
}
