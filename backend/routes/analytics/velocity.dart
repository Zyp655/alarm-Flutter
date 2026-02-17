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

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final dailyQuery = db.selectOnly(db.learningActivities)
      ..addColumns([
        db.learningActivities.createdAt,
        db.learningActivities.id.count(),
      ])
      ..where(db.learningActivities.userId.equals(userId))
      ..where(db.learningActivities.courseId.equals(courseId))
      ..where(db.learningActivities.activityType.equals('lesson_complete'))
      ..where(
          db.learningActivities.createdAt.isBiggerOrEqualValue(thirtyDaysAgo))
      ..groupBy([db.learningActivities.createdAt.date])
      ..orderBy([OrderingTerm.asc(db.learningActivities.createdAt)]);

    final dailyResults = await dailyQuery.get();

    final dailyProgress = dailyResults.map((row) {
      final date = row.read(db.learningActivities.createdAt);
      final count = row.read(db.learningActivities.id.count());
      return {
        'date': date?.toIso8601String().substring(0, 10),
        'lessonsCompleted': count ?? 0,
      };
    }).toList();

    final modulesInCourse = await (db.select(db.modules)
          ..where((t) => t.courseId.equals(courseId)))
        .get();
    final moduleIds = modulesInCourse.map((m) => m.id).toList();

    int totalLessons = 0;
    if (moduleIds.isNotEmpty) {
      final lessonsQuery = db.selectOnly(db.lessons)
        ..addColumns([db.lessons.id.count()])
        ..where(db.lessons.moduleId.isIn(moduleIds));
      final lessonsResult = await lessonsQuery.getSingle();
      totalLessons = lessonsResult.read(db.lessons.id.count()) ?? 0;
    }

    final completedQuery = db.selectOnly(db.lessonProgress)
      ..addColumns([db.lessonProgress.id.count()])
      ..where(db.lessonProgress.userId.equals(userId))
      ..where(db.lessonProgress.isCompleted.equals(true));

    if (moduleIds.isNotEmpty) {
      completedQuery.join([
        innerJoin(
            db.lessons, db.lessons.id.equalsExp(db.lessonProgress.lessonId)),
      ]);
      completedQuery.where(db.lessons.moduleId.isIn(moduleIds));
    }

    final completedResult = await completedQuery.getSingle();
    final completedLessons =
        completedResult.read(db.lessonProgress.id.count()) ?? 0;

    final remainingLessons = totalLessons - completedLessons;

    double? dailyVelocity;
    String? predictedDate;
    String trend = 'insufficient';
    double confidence = 0.0;

    if (dailyProgress.isNotEmpty) {
      double ema = (dailyProgress.first['lessonsCompleted'] as int).toDouble();
      for (int i = 1; i < dailyProgress.length; i++) {
        ema = 0.3 * (dailyProgress[i]['lessonsCompleted'] as int) + 0.7 * ema;
      }
      dailyVelocity = ema;

      if (ema > 0.01 && remainingLessons > 0) {
        final daysRemaining = (remainingLessons / ema).ceil();
        predictedDate = DateTime.now()
            .add(Duration(days: daysRemaining))
            .toIso8601String()
            .substring(0, 10);
      }

      confidence = (dailyProgress.length / 30.0).clamp(0.0, 1.0);

      if (dailyProgress.length >= 7) {
        final recent = dailyProgress.sublist(dailyProgress.length - 7);
        final older =
            dailyProgress.sublist(0, 7.clamp(0, dailyProgress.length));
        final recentAvg = recent.fold<double>(
                0, (s, e) => s + (e['lessonsCompleted'] as int)) /
            7;
        final olderAvg = older.fold<double>(
                0, (s, e) => s + (e['lessonsCompleted'] as int)) /
            older.length;
        if (recentAvg > olderAvg * 1.1) {
          trend = 'accelerating';
        } else if (recentAvg < olderAvg * 0.9) {
          trend = 'slowing';
        } else {
          trend = 'steady';
        }
      }
    }

    return Response.json(body: {
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'remainingLessons': remainingLessons,
      'dailyVelocity': dailyVelocity,
      'predictedCompletionDate': predictedDate,
      'trend': trend,
      'confidence': confidence,
      'dailyProgress': dailyProgress,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch velocity: $e'},
    );
  }
}
