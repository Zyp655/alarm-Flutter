import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final courseId = int.tryParse(id);
  if (courseId == null) {
    return Response(statusCode: 400, body: 'Invalid course ID');
  }

  final userId = context.read<int>();
  final request = context.request;

  final db = context.read<AppDatabase>();

  if (request.method == HttpMethod.get) {
    return _getStudyPlan(db, userId, courseId);
  } else if (request.method == HttpMethod.post) {
    return _createStudyPlan(context, db, userId, courseId);
  }

  return Response(statusCode: 405);
}

Future<Response> _getStudyPlan(AppDatabase db, int userId, int courseId) async {
  final plan = await (db.select(db.studyPlans)
        ..where((t) => t.userId.equals(userId) & t.courseId.equals(courseId)))
      .getSingleOrNull();

  if (plan == null) {
    return Response.json(body: {'hasPlan': false});
  }

  final scheduledLessons = await (db.select(db.scheduledLessons)
        ..where((t) => t.studyPlanId.equals(plan.id))
        ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
      .get();

  return Response.json(body: {
    'hasPlan': true,
    'plan': {
      'targetCompletionDate': plan.targetCompletionDate.toIso8601String(),
      'dailyStudyMinutes': plan.dailyStudyMinutes,
      'preferredDays': jsonDecode(plan.preferredDays),
      'reminderTime': plan.reminderTime,
    },
    'schedule': scheduledLessons
        .map((l) => {
              'id': l.id,
              'lessonId': l.lessonId,
              'date': l.scheduledDate.toIso8601String(),
              'isCompleted': l.isCompleted,
            })
        .toList(),
  });
}

Future<Response> _createStudyPlan(
  RequestContext context,
  AppDatabase db,
  int userId,
  int courseId,
) async {
  final body = await context.request.json();
  final targetDateStr = body['targetCompletionDate'] as String?;
  final dailyMinutes = body['dailyStudyMinutes'] as int? ?? 30;
  final preferredDaysRaw = body['preferredDays'] as List?;
  final reminderTime = body['reminderTime'] as String? ?? '19:00';

  if (targetDateStr == null) {
    return Response(statusCode: 400, body: 'Missing targetCompletionDate');
  }

  final targetDate = DateTime.parse(targetDateStr);
  final preferredDays = preferredDaysRaw?.map((e) => e.toString()).toList() ??
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  return await db.transaction(() async {
    final existingPlan = await (db.select(db.studyPlans)
          ..where((t) => t.userId.equals(userId) & t.courseId.equals(courseId)))
        .getSingleOrNull();

    if (existingPlan != null) {
      await (db.delete(db.scheduledLessons)
            ..where((t) => t.studyPlanId.equals(existingPlan.id)))
          .go();
      await (db.delete(db.studyPlans)
            ..where((t) => t.id.equals(existingPlan.id)))
          .go();
    }

    final planId = await db.into(db.studyPlans).insert(StudyPlansCompanion(
          userId: Value(userId),
          courseId: Value(courseId),
          targetCompletionDate: Value(targetDate),
          dailyStudyMinutes: Value(dailyMinutes),
          preferredDays: Value(jsonEncode(preferredDays)),
          reminderTime: Value(reminderTime),
          createdAt: Value(DateTime.now()),
        ));

    final modules = await (db.select(db.modules)
          ..where((t) => t.courseId.equals(courseId))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();

    final allLessons = <dynamic>[];
    for (final module in modules) {
      final lessons = await (db.select(db.lessons)
            ..where((t) => t.moduleId.equals(module.id))
            ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
          .get();
      allLessons.addAll(lessons);
    }

    final schedule = _generateSchedule(
      allLessons,
      targetDate,
      dailyMinutes,
      preferredDays,
      reminderTime,
    );

    for (final item in schedule) {
      await db.into(db.scheduledLessons).insert(ScheduledLessonsCompanion(
            studyPlanId: Value(planId),
            lessonId: Value(item['lessonId'] as int),
            scheduledDate: Value(item['date'] as DateTime),
            scheduledTime: Value(reminderTime),
          ));
    }

    return Response.json(body: {
      'success': true,
      'planId': planId,
      'lessonsScheduled': schedule.length,
    });
  });
}

List<Map<String, dynamic>> _generateSchedule(
  List<dynamic> lessons,
  DateTime targetDate,
  int dailyMinutes,
  List<String> preferredDays,
  String reminderTime,
) {
  final schedule = <Map<String, dynamic>>[];
  DateTime currentDate = DateTime.now().add(const Duration(days: 1));
  int minutesAllocatedToday = 0;

  bool isPreferredDay(DateTime date) {
    const dayMap = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun'
    };
    final dayName = dayMap[date.weekday];
    return preferredDays.contains(dayName);
  }

  for (final lesson in lessons) {
    while (true) {
      if (currentDate.isAfter(targetDate)) {}

      if (isPreferredDay(currentDate)) {
        final duration = (lesson.durationMinutes as int?) ?? 15;
        if (minutesAllocatedToday + duration <= dailyMinutes * 1.5) {
          schedule.add({
            'lessonId': lesson.id,
            'date': currentDate,
          });
          minutesAllocatedToday += duration;
          break;
        } else {
          currentDate = currentDate.add(const Duration(days: 1));
          minutesAllocatedToday = 0;
          continue;
        }
      } else {
        currentDate = currentDate.add(const Duration(days: 1));
        minutesAllocatedToday = 0;
      }
    }
  }

  return schedule;
}
