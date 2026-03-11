import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<AppDatabase>();
  final params = context.request.uri.queryParameters;
  final classId = int.tryParse(params['classId'] ?? '');
  final dateStr = params['date'];

  if (classId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'classId is required'},
    );
  }

  final date = dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();
  if (date == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid date'});
  }

  final dayStart = DateTime(date.year, date.month, date.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final enrollments = await (db.select(db.courseClassEnrollments)
        ..where((e) => e.courseClassId.equals(classId)))
      .get();

  final results = <Map<String, dynamic>>[];

  for (final enrollment in enrollments) {
    final student = await (db.select(db.users)
          ..where((u) => u.id.equals(enrollment.studentId)))
        .getSingleOrNull();
    if (student == null) continue;

    final schedules = await (db.select(db.schedules)
          ..where((s) => s.userId.equals(enrollment.studentId))
          ..where((s) => s.startTime.isBiggerOrEqualValue(dayStart))
          ..where((s) => s.startTime.isSmallerThanValue(dayEnd))
          ..where((s) => s.type.equals('classSession')))
        .get();

    double totalWatchPct = 0;
    bool allQuizDone = true;
    String finalStatus = 'not_accessed';
    String? absenceReason;
    int currentAbsences = 0;
    int maxAbsences = 6;

    for (final schedule in schedules) {
      currentAbsences = schedule.currentAbsences;
      maxAbsences = schedule.maxAbsences;

      final log = await (db.select(db.dailyLearningLogs)
            ..where((l) => l.studentId.equals(enrollment.studentId))
            ..where((l) => l.scheduleId.equals(schedule.id))
            ..where((l) => l.date.isBiggerOrEqualValue(dayStart))
            ..where((l) => l.date.isSmallerThanValue(dayEnd)))
          .getSingleOrNull();

      if (log != null) {
        totalWatchPct = log.watchPercentage;
        allQuizDone = log.quizCompleted;
        finalStatus = log.status;
        absenceReason = log.absenceReason;
      }
    }

    results.add({
      'studentId': enrollment.studentId,
      'fullName': student.fullName ?? student.email,
      'email': student.email,
      'status': finalStatus,
      'watchPercentage': totalWatchPct,
      'quizCompleted': allQuizDone,
      'absenceReason': absenceReason,
      'currentAbsences': currentAbsences,
      'maxAbsences': maxAbsences,
    });
  }

  final present = results.where((r) => r['status'] == 'present').length;
  final absent = results.where((r) => r['status'] == 'absent').length;
  final pending = results
      .where((r) => r['status'] == 'pending' || r['status'] == 'not_accessed')
      .length;

  return Response.json(body: {
    'classId': classId,
    'date': dayStart.toIso8601String(),
    'summary': {
      'total': results.length,
      'present': present,
      'absent': absent,
      'pending': pending,
    },
    'students': results,
  });
}
