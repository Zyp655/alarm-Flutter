import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final method = request.method;
  final courseId = int.tryParse(id);
  if (courseId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid course ID'},
    );
  }
  if (method == HttpMethod.get) {
    return _getCourseDetails(context, courseId);
  } else if (method == HttpMethod.put) {
    return _updateCourse(context, courseId);
  } else if (method == HttpMethod.delete) {
    return _deleteCourse(context, courseId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getCourseDetails(RequestContext context, int courseId) async {
  try {
    final db = context.read<AppDatabase>();
    final course = await (db.select(db.courses)
          ..where((tbl) => tbl.id.equals(courseId)))
        .getSingleOrNull();
    if (course == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Course not found'},
      );
    }
    final modules = await (db.select(db.modules)
          ..where((tbl) => tbl.courseId.equals(courseId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
        .get();
    final modulesWithLessons = <Map<String, dynamic>>[];
    int totalDuration = 0;
    for (final module in modules) {
      final lessons = await (db.select(db.lessons)
            ..where((tbl) => tbl.moduleId.equals(module.id))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
          .get();
      for (final lesson in lessons) {
        totalDuration += lesson.durationMinutes;
      }
      modulesWithLessons.add({
        'id': module.id,
        'title': module.title,
        'description': module.description,
        'orderIndex': module.orderIndex,
        'lessons': lessons
            .map((lesson) => {
                  'id': lesson.id,
                  'title': lesson.title,
                  'type': lesson.type,
                  'contentUrl': lesson.contentUrl,
                  'durationMinutes': lesson.durationMinutes,
                  'isFreePreview': lesson.isFreePreview,
                  'orderIndex': lesson.orderIndex,
                })
            .toList(),
      });
    }
  
    final studentCount = await (db.select(db.enrollments)
          ..where((e) => e.courseId.equals(courseId)))
        .get()
        .then((rows) => rows.length);

    final reviews = await (db.select(db.courseReviews)
          ..where((r) => r.courseId.equals(courseId)))
        .get();
    double averageRating = 0;
    if (reviews.isNotEmpty) {
      final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
      averageRating = total / reviews.length;
    }

    return Response.json(body: {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'thumbnailUrl': course.thumbnailUrl,
      'instructorId': course.instructorId,
      'price': course.price,
      'tags': course.tags,
      'level': course.level,
      'durationMinutes': totalDuration,
      'studentCount': studentCount,
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      'reviewsCount': reviews.length,
      'isPublished': course.isPublished,
      'modules': modulesWithLessons,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch course details: $e'},
    );
  }
}

Future<Response> _updateCourse(RequestContext context, int courseId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final updated = await db.update(db.courses)
      ..where((tbl) => tbl.id.equals(courseId));
    final count = await updated.write(
      CoursesCompanion(
        title: body.containsKey('title')
            ? Value(body['title'] as String)
            : const Value.absent(),
        description: body.containsKey('description')
            ? Value(body['description'] as String?)
            : const Value.absent(),
        thumbnailUrl: body.containsKey('thumbnailUrl')
            ? Value(body['thumbnailUrl'] as String?)
            : const Value.absent(),
        price: body.containsKey('price')
            ? Value((body['price'] as num).toDouble())
            : const Value.absent(),
        tags: body.containsKey('tags')
            ? Value(body['tags'] as String?)
            : const Value.absent(),
        level: body.containsKey('level')
            ? Value(body['level'] as String)
            : const Value.absent(),
        durationMinutes: body.containsKey('durationMinutes')
            ? Value(body['durationMinutes'] as int)
            : const Value.absent(),
        isPublished: body.containsKey('isPublished')
            ? Value(body['isPublished'] as bool)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (count == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Course not found'},
      );
    }
    return Response.json(body: {'message': 'Course updated successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update course: $e'},
    );
  }
}

Future<Response> _deleteCourse(RequestContext context, int courseId) async {
  try {
    final db = context.read<AppDatabase>();
    final count = await (db.delete(db.courses)
          ..where((tbl) => tbl.id.equals(courseId)))
        .go();
    if (count == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Course not found'},
      );
    }
    return Response.json(body: {'message': 'Course deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete course: $e'},
    );
  }
}
