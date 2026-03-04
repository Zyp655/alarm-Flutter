import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getAcademicCourses(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getAcademicCourses(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final departmentId = int.tryParse(params['departmentId'] ?? '');
    final courseType = params['courseType'];
    final search = params['search'];

    var query = db.select(db.academicCourses);

    if (departmentId != null) {
      query = query..where((c) => c.departmentId.equals(departmentId));
    }
    if (courseType != null) {
      query = query..where((c) => c.courseType.equals(courseType));
    }
    if (search != null && search.isNotEmpty) {
      query = query
        ..where(
          (c) => c.name.like('%$search%') | c.code.like('%$search%'),
        );
    }

    query = query..where((c) => c.isPublished.equals(true));

    final courses = await query.get();

    final results = <Map<String, dynamic>>[];
    for (final course in courses) {
      final dept = await (db.select(db.departments)
            ..where((d) => d.id.equals(course.departmentId)))
          .getSingleOrNull();

      final moduleCount = await (db.selectOnly(db.modules)
            ..addColumns([countAll()])
            ..where(db.modules.academicCourseId.equals(course.id)))
          .map((row) => row.read(countAll()) ?? 0)
          .getSingle();

      final classCount = await (db.selectOnly(db.courseClasses)
            ..addColumns([countAll()])
            ..where(db.courseClasses.academicCourseId.equals(course.id)))
          .map((row) => row.read(countAll()) ?? 0)
          .getSingle();

      results.add({
        'id': course.id,
        'name': course.name,
        'code': course.code,
        'credits': course.credits,
        'courseType': course.courseType,
        'description': course.description,
        'thumbnailUrl': course.thumbnailUrl,
        'departmentId': course.departmentId,
        'departmentName': dept?.name,
        'moduleCount': moduleCount,
        'classCount': classCount,
        'isPublished': course.isPublished,
        'createdAt': course.createdAt.toIso8601String(),
      });
    }

    return Response.json(body: {'courses': results});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi khi tải danh sách học phần: $e'},
    );
  }
}
