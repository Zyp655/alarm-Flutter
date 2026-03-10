import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  final query = (params['q'] ?? '').trim().toLowerCase();

  if (query.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Query parameter "q" is required'},
    );
  }

  final typeFilter = params['type'];
  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
  final offset = (page - 1) * limit;

  try {
    final results = <Map<String, dynamic>>[];

    if (typeFilter == null || typeFilter == 'course') {
      final courseQuery = db.select(db.courses)
        ..where(
          (c) =>
              c.title.lower().like('%$query%') |
              c.description.lower().like('%$query%') |
              c.tags.lower().like('%$query%'),
        )
        ..where((c) => c.isPublished.equals(true))
        ..limit(limit, offset: offset);

      final courses = await courseQuery.get();

      for (final c in courses) {

        final instructor = await (db.select(db.users)
              ..where((u) => u.id.equals(c.instructorId)))
            .getSingleOrNull();

        final reviews = await (db.select(db.courseReviews)
              ..where((r) => r.courseId.equals(c.id)))
            .get();
        double? avgRating;
        if (reviews.isNotEmpty) {
          avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
              reviews.length;
        }

        results.add({
          'id': c.id,
          'type': 'course',
          'title': c.title,
          'subtitle': instructor?.fullName ?? 'Unknown instructor',
          'rating': avgRating != null
              ? double.parse(avgRating.toStringAsFixed(1))
              : null,
          'thumbnailUrl': c.thumbnailUrl,
          'metadata': {
            'level': c.level,
            'price': c.price,
          },
        });
      }
    }

    if (typeFilter == null || typeFilter == 'teacher') {
      final teacherQuery = db.select(db.users)
        ..where(
          (u) => u.role.equals(1) & u.fullName.lower().like('%$query%'),
        )
        ..limit(limit, offset: offset);

      final teachers = await teacherQuery.get();

      for (final t in teachers) {

        final courseCount = await (db.selectOnly(db.courses)
              ..addColumns([db.courses.id.count()])
              ..where(db.courses.instructorId.equals(t.id))
              ..where(db.courses.isPublished.equals(true)))
            .getSingle()
            .then((row) => row.read(db.courses.id.count()) ?? 0);

        results.add({
          'id': t.id,
          'type': 'teacher',
          'title': t.fullName ?? t.email,
          'subtitle': '$courseCount khóa học',
          'rating': null,
          'metadata': {
            'email': t.email,
          },
        });
      }
    }

    if (typeFilter == null || typeFilter == 'lesson') {
      final lessonQuery = db.select(db.lessons).join([
        innerJoin(db.modules, db.modules.id.equalsExp(db.lessons.moduleId)),
        innerJoin(db.courses, db.courses.id.equalsExp(db.modules.courseId)),
      ]);
      lessonQuery.where(db.lessons.title.lower().like('%$query%'));
      lessonQuery.where(db.courses.isPublished.equals(true));
      lessonQuery.orderBy([OrderingTerm.asc(db.lessons.title)]);
      lessonQuery.limit(limit, offset: offset);

      final lessonRows = await lessonQuery.get();

      for (final row in lessonRows) {
        final lesson = row.readTable(db.lessons);
        final course = row.readTable(db.courses);

        results.add({
          'id': lesson.id,
          'type': 'lesson',
          'title': lesson.title,
          'subtitle': course.title,
          'rating': null,
          'metadata': {
            'courseId': course.id,
            'type': lesson.type,
            'durationMinutes': lesson.durationMinutes,
          },
        });
      }
    }

    return Response.json(body: {
      'query': query,
      'type': typeFilter,
      'results': results,
      'pagination': {
        'page': page,
        'limit': limit,
      },
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
