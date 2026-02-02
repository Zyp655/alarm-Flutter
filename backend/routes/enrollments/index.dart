import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;
  if (method == HttpMethod.post) {
    return _enrollCourse(context);
  } else if (method == HttpMethod.get) {
    return _getMyEnrollments(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _enrollCourse(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    if (!body.containsKey('userId') || !body.containsKey('courseId')) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId and courseId are required'},
      );
    }
    final userId = body['userId'] as int;
    final courseId = body['courseId'] as int;
    final existing = await (db.select(db.enrollments)
          ..where((tbl) =>
              tbl.userId.equals(userId) & tbl.courseId.equals(courseId)))
        .getSingleOrNull();
    if (existing != null) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Already enrolled in this course'},
      );
    }
    final course = await (db.select(db.courses)
          ..where((tbl) => tbl.id.equals(courseId)))
        .getSingleOrNull();
    if (course == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Course not found'},
      );
    }
    final enrollment = await db.into(db.enrollments).insertReturning(
          EnrollmentsCompanion.insert(
            userId: userId,
            courseId: courseId,
            enrolledAt: DateTime.now(),
          ),
        );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'message': 'Successfully enrolled in course',
        'enrollment': {
          'id': enrollment.id,
          'userId': enrollment.userId,
          'courseId': enrollment.courseId,
          'progressPercent': enrollment.progressPercent,
          'enrolledAt': enrollment.enrolledAt.toIso8601String(),
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to enroll: $e'},
    );
  }
}

Future<Response> _getMyEnrollments(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final queryParams = context.request.uri.queryParameters;
    if (!queryParams.containsKey('userId')) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId query parameter is required'},
      );
    }
    final userId = int.parse(queryParams['userId']!);
    final enrollments = await (db.select(db.enrollments)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.enrolledAt)]))
        .get();
    final enrollmentsWithCourses = <Map<String, dynamic>>[];
    for (final enrollment in enrollments) {
      final course = await (db.select(db.courses)
            ..where((tbl) => tbl.id.equals(enrollment.courseId)))
          .getSingle();
      enrollmentsWithCourses.add({
        'id': enrollment.id,
        'userId': enrollment.userId,
        'courseId': enrollment.courseId,
        'progressPercent': enrollment.progressPercent,
        'enrolledAt': enrollment.enrolledAt.toIso8601String(),
        'completedAt': enrollment.completedAt?.toIso8601String(),
        'lastAccessedAt': enrollment.lastAccessedAt?.toIso8601String(),
        'course': {
          'title': course.title,
          'description': course.description,
          'thumbnailUrl': course.thumbnailUrl,
          'instructorId': course.instructorId,
          'level': course.level,
          'durationMinutes': course.durationMinutes,
        },
      });
    }
    return Response.json(body: {'enrollments': enrollmentsWithCourses});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch enrollments: $e'},
    );
  }
}
