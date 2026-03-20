import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final courseId = int.tryParse(id);
  if (courseId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid course ID'},
    );
  }
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  try {
    final db = context.read<AppDatabase>();

    var courseName = '';
    var isAcademic = false;

    final course = await (db.select(db.courses)
          ..where((c) => c.id.equals(courseId)))
        .getSingleOrNull();

    if (course != null) {
      courseName = course.title;
    } else {
      final academicCourse = await (db.select(db.academicCourses)
            ..where((c) => c.id.equals(courseId)))
          .getSingleOrNull();
      if (academicCourse != null) {
        courseName = academicCourse.name;
        isAcademic = true;
      } else {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: {'error': 'Course not found'},
        );
      }
    }

    int totalEnrollments = 0;
    int notStarted = 0;
    int inProgress = 0;
    int completed = 0;
    int totalLessons = 0;
    double avgRating = 0;
    int totalReviews = 0;
    int recentActivityCount = 0;

    if (isAcademic) {
      final classes = await (db.select(db.courseClasses)
            ..where((c) => c.academicCourseId.equals(courseId)))
          .get();

      for (final cls in classes) {
        final members = await (db.select(db.courseClassEnrollments)
              ..where((m) => m.courseClassId.equals(cls.id)))
            .get();
        totalEnrollments += members.length;
      }

      final modules = await (db.select(db.modules)
            ..where((m) => m.academicCourseId.equals(courseId)))
          .get();
      final moduleIds = modules.map((m) => m.id).toList();
      if (moduleIds.isNotEmpty) {
        final lessons = await (db.select(db.lessons)
              ..where((l) => l.moduleId.isIn(moduleIds)))
            .get();
        totalLessons = lessons.length;
      }
    } else {
      final enrollments = await (db.select(db.enrollments)
            ..where((e) => e.courseId.equals(courseId)))
          .get();
      totalEnrollments = enrollments.length;

      for (final enrollment in enrollments) {
        if (enrollment.completedAt != null) {
          completed++;
        } else if (enrollment.progressPercent > 0) {
          inProgress++;
        } else {
          notStarted++;
        }
      }

      final modules = await (db.select(db.modules)
            ..where((m) => m.courseId.equals(courseId)))
          .get();
      final moduleIds = modules.map((m) => m.id).toList();
      if (moduleIds.isNotEmpty) {
        final lessons = await (db.select(db.lessons)
              ..where((l) => l.moduleId.isIn(moduleIds)))
            .get();
        totalLessons = lessons.length;
      }

      final reviews = await (db.select(db.courseReviews)
            ..where((r) => r.courseId.equals(courseId)))
          .get();
      totalReviews = reviews.length;
      if (reviews.isNotEmpty) {
        final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
        avgRating = total / reviews.length;
      }

      final recentActivity = await (db.select(db.studentActivityLogs)
            ..where((a) => a.courseId.equals(courseId)))
          .get();
      recentActivityCount = recentActivity.length;
    }

    return Response.json(
      body: {
        'courseId': courseId,
        'courseName': courseName,
        'totalEnrollments': totalEnrollments,
        'totalLessons': totalLessons,
        'studentStatus': {
          'notStarted': notStarted,
          'inProgress': inProgress,
          'completed': completed,
        },
        'completionRate': totalEnrollments > 0
            ? (completed / totalEnrollments * 100).round()
            : 0,
        'rating': {
          'average': double.parse(avgRating.toStringAsFixed(1)),
          'totalReviews': totalReviews,
        },
        'recentActivityCount': recentActivityCount,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}

