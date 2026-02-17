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
    final months = int.tryParse(params['months'] ?? '6') ?? 6;

    if (userId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId is required'},
      );
    }

    final startDate = DateTime.now().subtract(Duration(days: months * 30));

    final query = db.selectOnly(db.learningActivities)
      ..addColumns([
        db.learningActivities.createdAt,
        db.learningActivities.id.count(),
        db.learningActivities.durationMinutes.sum(),
      ])
      ..where(db.learningActivities.userId.equals(userId))
      ..where(db.learningActivities.createdAt.isBiggerOrEqualValue(startDate))
      ..groupBy([db.learningActivities.createdAt.date])
      ..orderBy([OrderingTerm.asc(db.learningActivities.createdAt)]);

    final results = await query.get();

    final heatmapData = results.map((row) {
      final date = row.read(db.learningActivities.createdAt);
      final count = row.read(db.learningActivities.id.count());
      final minutes = row.read(db.learningActivities.durationMinutes.sum());
      return {
        'date': date?.toIso8601String().substring(0, 10),
        'activityCount': count ?? 0,
        'totalMinutes': minutes ?? 0,
      };
    }).toList();

    final streakRow = await (db.select(db.userStreaks)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    return Response.json(body: {
      'heatmap': heatmapData,
      'streak': streakRow != null
          ? {
              'current': streakRow.currentStreak,
              'longest': streakRow.longestStreak,
              'totalDays': streakRow.totalDaysActive,
            }
          : {'current': 0, 'longest': 0, 'totalDays': 0},
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch heatmap: $e'},
    );
  }
}
