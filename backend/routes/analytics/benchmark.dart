import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final userId = int.tryParse(params['userId'] ?? '');
    final courseId = int.tryParse(params['courseId'] ?? '');

    if (userId == null || courseId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId and courseId are required'},
      );
    }

    final userEnrollment = await (db.select(db.enrollments)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.courseId.equals(courseId)))
        .getSingleOrNull();

    final myProgress = userEnrollment?.progressPercent ?? 0.0;

    final avgQuery = db.selectOnly(db.enrollments)
      ..addColumns([
        db.enrollments.progressPercent.avg(),
        db.enrollments.progressPercent.max(),
        db.enrollments.id.count(),
      ])
      ..where(db.enrollments.courseId.equals(courseId));

    final avgResult = await avgQuery.getSingle();
    final avgProgress =
        avgResult.read(db.enrollments.progressPercent.avg()) ?? 0.0;
    final topProgress =
        avgResult.read(db.enrollments.progressPercent.max()) ?? 0.0;
    final totalStudents = avgResult.read(db.enrollments.id.count()) ?? 0;

    final myTimeQuery = db.selectOnly(db.learningActivities)
      ..addColumns([db.learningActivities.durationMinutes.sum()])
      ..where(db.learningActivities.userId.equals(userId))
      ..where(db.learningActivities.courseId.equals(courseId));

    final myTimeResult = await myTimeQuery.getSingle();
    final myStudyMinutes =
        myTimeResult.read(db.learningActivities.durationMinutes.sum()) ?? 0;

    final avgTimeQuery = db.selectOnly(db.learningActivities)
      ..addColumns([db.learningActivities.durationMinutes.sum()])
      ..where(db.learningActivities.courseId.equals(courseId))
      ..groupBy([db.learningActivities.userId]);

    final avgTimeResults = await avgTimeQuery.get();
    double avgStudyMinutes = 0;
    if (avgTimeResults.isNotEmpty) {
      final totalMinutes = avgTimeResults.fold<int>(
        0,
        (sum, row) =>
            sum + (row.read(db.learningActivities.durationMinutes.sum()) ?? 0),
      );
      avgStudyMinutes = totalMinutes / avgTimeResults.length;
    }

    int studentsBelow = 0;
    if (totalStudents > 0) {
      final belowQuery = db.selectOnly(db.enrollments)
        ..addColumns([db.enrollments.id.count()])
        ..where(db.enrollments.courseId.equals(courseId))
        ..where(db.enrollments.progressPercent.isSmallerThanValue(myProgress));
      final belowResult = await belowQuery.getSingle();
      studentsBelow = belowResult.read(db.enrollments.id.count()) ?? 0;
    }

    final percentileRank =
        totalStudents > 0 ? (studentsBelow / totalStudents * 100).round() : 0;

    return Response.json(body: {
      'myProgress': myProgress,
      'avgProgress': avgProgress,
      'topProgress': topProgress,
      'totalStudents': totalStudents,
      'percentileRank': percentileRank,
      'myStudyMinutes': myStudyMinutes,
      'avgStudyMinutes': avgStudyMinutes.round(),
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch benchmark: $e'},
    );
  }
}
