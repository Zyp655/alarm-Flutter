import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';


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
    final params = context.request.uri.queryParameters;
    final statusFilter =
        params['status']; 

    final enrollments = await (db.select(db.enrollments)
          ..where((e) => e.courseId.equals(courseId)))
        .get();

    final modules = await (db.select(db.modules)
          ..where((m) => m.courseId.equals(courseId)))
        .get();
    final moduleIds = modules.map((m) => m.id).toList();

    int totalLessons = 0;
    if (moduleIds.isNotEmpty) {
      final lessons = await (db.select(db.lessons)
            ..where((l) => l.moduleId.isIn(moduleIds)))
          .get();
      totalLessons = lessons.length;
    }

    final List<Map<String, dynamic>> students = [];

    for (final enrollment in enrollments) {
      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(enrollment.userId)))
          .getSingleOrNull();

      if (user == null) continue;

      int completedLessons = 0;
      if (moduleIds.isNotEmpty) {
        final lessons = await (db.select(db.lessons)
              ..where((l) => l.moduleId.isIn(moduleIds)))
            .get();
        final lessonIds = lessons.map((l) => l.id).toList();

        if (lessonIds.isNotEmpty) {
          final progress = await (db.select(db.lessonProgress)
                ..where((p) => p.userId.equals(enrollment.userId))
                ..where((p) => p.lessonId.isIn(lessonIds))
                ..where((p) => p.isCompleted.equals(true)))
              .get();
          completedLessons = progress.length;
        }
      }

      final progressPercent = totalLessons > 0
          ? (completedLessons / totalLessons * 100).round()
          : 0;

      String status;
      if (completedLessons == 0) {
        status = 'not_started';
      } else if (completedLessons >= totalLessons) {
        status = 'completed';
      } else {
        status = 'in_progress';
      }

      if (statusFilter != null && status != statusFilter) {
        continue;
      }

      final lastActivity = await (db.select(db.studentActivityLogs)
            ..where((a) => a.userId.equals(enrollment.userId))
            ..where((a) => a.courseId.equals(courseId))
            ..orderBy([(a) => OrderingTerm.desc(a.timestamp)])
            ..limit(1))
          .getSingleOrNull();

      students.add({
        'userId': user.id,
        'email': user.email,
        'fullName': user.fullName ?? 'Unknown',
        'enrolledAt': enrollment.enrolledAt.toIso8601String(),
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'progressPercent': progressPercent,
        'status': status,
        'lastAccessedAt': enrollment.lastAccessedAt?.toIso8601String(),
        'lastActivity': lastActivity != null
            ? {
                'action': lastActivity.action,
                'timestamp': lastActivity.timestamp.toIso8601String(),
              }
            : null,
      });
    }

    return Response.json(
      body: {
        'courseId': courseId,
        'totalStudents': students.length,
        'students': students,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch students: $e'},
    );
  }
}
