import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:backend/services/attendance_engine.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();
  final engine = AttendanceEngine(db);
  final userId = context.read<int>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getLog(db, userId, context);
    case HttpMethod.post:
      return _trackWatchTime(db, engine, userId, context);
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _getLog(
  AppDatabase db,
  int userId,
  RequestContext context,
) async {
  final params = context.request.uri.queryParameters;
  final scheduleIdStr = params['scheduleId'];
  final dateStr = params['date'];

  final date = dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();
  if (date == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid date'});
  }

  final dayStart = DateTime(date.year, date.month, date.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  if (scheduleIdStr != null) {
    final scheduleId = int.tryParse(scheduleIdStr);
    if (scheduleId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid scheduleId'},
      );
    }

    final log = await (db.select(db.dailyLearningLogs)
          ..where((l) => l.studentId.equals(userId))
          ..where((l) => l.scheduleId.equals(scheduleId))
          ..where((l) => l.date.isBiggerOrEqualValue(dayStart))
          ..where((l) => l.date.isSmallerThanValue(dayEnd)))
        .getSingleOrNull();

    return Response.json(body: {
      'log': log != null ? _logToJson(log) : null,
    });
  }

  final logs = await (db.select(db.dailyLearningLogs)
        ..where((l) => l.studentId.equals(userId))
        ..where((l) => l.date.isBiggerOrEqualValue(dayStart))
        ..where((l) => l.date.isSmallerThanValue(dayEnd)))
      .get();

  return Response.json(body: {
    'logs': logs.map(_logToJson).toList(),
    'date': dayStart.toIso8601String(),
  });
}

Future<Response> _trackWatchTime(
  AppDatabase db,
  AttendanceEngine engine,
  int userId,
  RequestContext context,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final scheduleId = body['scheduleId'] as int?;
  final watchSeconds = body['watchSeconds'] as int?;
  final quizCompleted = body['quizCompleted'] as bool?;
  final quizScore = (body['quizScore'] as num?)?.toDouble();

  if (scheduleId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'scheduleId is required'},
    );
  }

  try {
    final log = await engine.getOrCreateLog(
      studentId: userId,
      scheduleId: scheduleId,
      date: DateTime.now(),
    );

    if (log.status != 'pending') {
      return Response.json(body: {
        'message': 'Log đã finalize',
        'status': log.status,
        'log': _logToJson(log),
      });
    }

    if (watchSeconds != null && watchSeconds > 0) {
      await engine.updateWatchTime(
        logId: log.id,
        additionalSeconds: watchSeconds,
      );
    }

    final skipCount = body['skipCount'] as int? ?? 0;
    final rewindCount = body['rewindCount'] as int? ?? 0;
    final pauseCount = body['pauseCount'] as int? ?? 0;
    if (skipCount > 0 || rewindCount > 0 || pauseCount > 0) {
      try {
        await db.into(db.learningActivities).insert(
          LearningActivitiesCompanion.insert(
            userId: userId,
            activityType: 'video_behavior',
            durationMinutes: Value((watchSeconds ?? 0) ~/ 60),
            metadata: Value('{"skipCount":$skipCount,"rewindCount":$rewindCount,"pauseCount":$pauseCount}'),
            createdAt: DateTime.now(),
          ),
        );
      } catch (_) {}
    }

    if (quizCompleted == true) {
      await engine.markQuizCompleted(logId: log.id, score: quizScore);
    }

    final updated = await (db.select(db.dailyLearningLogs)
          ..where((l) => l.id.equals(log.id)))
        .getSingle();

    return Response.json(body: {
      'message': 'Cập nhật thành công',
      'log': _logToJson(updated),
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Lỗi: $e'},
    );
  }
}

Map<String, dynamic> _logToJson(DailyLearningLog log) {
  return {
    'id': log.id,
    'studentId': log.studentId,
    'scheduleId': log.scheduleId,
    'date': log.date.toIso8601String(),
    'totalWatchSeconds': log.totalWatchSeconds,
    'requiredWatchSeconds': log.requiredWatchSeconds,
    'watchPercentage': log.watchPercentage,
    'quizCompleted': log.quizCompleted,
    'quizScore': log.quizScore,
    'firstAccessAt': log.firstAccessAt?.toIso8601String(),
    'lastAccessAt': log.lastAccessAt?.toIso8601String(),
    'status': log.status,
    'absenceReason': log.absenceReason,
    'finalizedAt': log.finalizedAt?.toIso8601String(),
  };
}
