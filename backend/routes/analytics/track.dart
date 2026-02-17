import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final userId = body['userId'] as int?;
    final activityType = body['activityType'] as String?;

    if (userId == null || activityType == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId and activityType are required'},
      );
    }

    final courseId = body['courseId'] as int?;
    final lessonId = body['lessonId'] as int?;
    final durationMinutes = body['durationMinutes'] as int? ?? 0;
    final metadata = body['metadata'] as String?;

    final id = await db.into(db.learningActivities).insert(
          LearningActivitiesCompanion.insert(
            userId: userId,
            courseId: Value(courseId),
            lessonId: Value(lessonId),
            activityType: activityType,
            durationMinutes: Value(durationMinutes),
            metadata: Value(metadata),
            createdAt: DateTime.now(),
          ),
        );

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final existingStreak = await (db.select(db.userStreaks)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (existingStreak != null) {
      final lastActivity = existingStreak.lastActivityDate;
      final lastDate = lastActivity != null
          ? DateTime(lastActivity.year, lastActivity.month, lastActivity.day)
          : null;

      if (lastDate == null || lastDate.isBefore(todayDate)) {
        int newStreak = existingStreak.currentStreak;

        if (lastDate != null) {
          final diff = todayDate.difference(lastDate).inDays;
          if (diff == 1) {
            newStreak += 1;
          } else if (diff > 1) {
            newStreak = 1;
          }
        } else {
          newStreak = 1;
        }

        await (db.update(db.userStreaks)..where((t) => t.userId.equals(userId)))
            .write(
          UserStreaksCompanion(
            currentStreak: Value(newStreak),
            longestStreak: Value(newStreak > existingStreak.longestStreak
                ? newStreak
                : existingStreak.longestStreak),
            lastActivityDate: Value(todayDate),
            totalDaysActive: Value(existingStreak.totalDaysActive +
                (lastDate != todayDate ? 1 : 0)),
          ),
        );
      }
    } else {
      await db.into(db.userStreaks).insert(
            UserStreaksCompanion.insert(
              userId: userId,
              currentStreak: const Value(1),
              longestStreak: const Value(1),
              lastActivityDate: Value(todayDate),
              totalDaysActive: const Value(1),
            ),
          );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'message': 'Activity tracked successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to track activity: $e'},
    );
  }
}
