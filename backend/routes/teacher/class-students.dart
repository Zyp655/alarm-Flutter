import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final params = context.request.uri.queryParameters;
  final classId = int.tryParse(params['classId'] ?? '');

  if (classId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'classId là bắt buộc'},
    );
  }

  final lessonId = int.tryParse(params['lessonId'] ?? '');

  try {
    final db = context.read<AppDatabase>();

    final cls = await (db.select(db.courseClasses)
          ..where((c) => c.id.equals(classId)))
        .getSingleOrNull();

    if (cls == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Không tìm thấy lớp'},
      );
    }

    final enrollments = await (db.select(db.courseClassEnrollments)
          ..where((e) =>
              e.courseClassId.equals(classId) & e.status.equals('enrolled')))
        .get();

    if (enrollments.isEmpty) {
      return Response.json(body: {
        'classId': classId,
        'lessonId': lessonId,
        'total': 0,
        'viewed': 0,
        'late': 0,
        'absent': 0,
        'students': <Map<String, dynamic>>[],
      });
    }

    final allLessons = <int>[];
    final modules = await (db.select(db.modules)
          ..where((m) => m.academicCourseId.equals(cls.academicCourseId)))
        .get();
    for (final mod in modules) {
      final lessons = await (db.select(db.lessons)
            ..where((l) => l.moduleId.equals(mod.id)))
          .get();
      allLessons.addAll(lessons.map((l) => l.id));
    }

    final totalLessons = allLessons.length;

    final studentList = <Map<String, dynamic>>[];
    int viewedCount = 0;
    int lateCount = 0;
    int absentCount = 0;

    for (final enrollment in enrollments) {
      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(enrollment.studentId)))
          .getSingleOrNull();

      if (user == null) continue;

      final profile = await (db.select(db.studentProfiles)
            ..where((p) => p.userId.equals(user.id)))
          .getSingleOrNull();

      if (lessonId != null) {
        final progress = await (db.select(db.lessonProgress)
              ..where((p) =>
                  p.userId.equals(user.id) & p.lessonId.equals(lessonId)))
            .getSingleOrNull();

        String status;
        DateTime? lastAccessAt;
        int watchedPosition = 0;
        bool completed = false;

        if (progress == null) {
          status = 'absent';
          absentCount++;
        } else {
          lastAccessAt = progress.updatedAt;
          watchedPosition = progress.lastWatchedPosition;
          completed = progress.isCompleted;

          final hoursSinceAccess =
              DateTime.now().difference(progress.updatedAt).inHours;

          if (completed || watchedPosition > 0) {
            if (hoursSinceAccess > 48 && !completed) {
              status = 'late';
              lateCount++;
            } else {
              status = 'viewed';
              viewedCount++;
            }
          } else {
            status = 'absent';
            absentCount++;
          }
        }

        studentList.add({
          'userId': user.id,
          'fullName': user.fullName ?? user.email,
          'email': user.email,
          'studentId': profile?.studentId ?? '',
          'status': status,
          'lastAccessAt': lastAccessAt?.toIso8601String(),
          'lastWatchedPosition': watchedPosition,
          'isCompleted': completed,
        });
      } else {
        int completedLessons = 0;
        DateTime? latestAccess;

        for (final lId in allLessons) {
          final progress = await (db.select(db.lessonProgress)
                ..where(
                    (p) => p.userId.equals(user.id) & p.lessonId.equals(lId)))
              .getSingleOrNull();

          if (progress != null) {
            if (progress.isCompleted) completedLessons++;
            if (latestAccess == null ||
                progress.updatedAt.isAfter(latestAccess)) {
              latestAccess = progress.updatedAt;
            }
          }
        }

        String status;
        if (latestAccess == null) {
          status = 'absent';
          absentCount++;
        } else {
          final hoursSince = DateTime.now().difference(latestAccess).inHours;
          if (hoursSince <= 24) {
            status = 'viewed';
            viewedCount++;
          } else if (hoursSince <= 168) {
            status = 'late';
            lateCount++;
          } else {
            status = 'absent';
            absentCount++;
          }
        }

        studentList.add({
          'userId': user.id,
          'fullName': user.fullName ?? user.email,
          'email': user.email,
          'studentId': profile?.studentId ?? '',
          'status': status,
          'lastAccessAt': latestAccess?.toIso8601String(),
          'lessonsCompleted': completedLessons,
          'totalLessons': totalLessons,
          'progressPercent': totalLessons > 0
              ? (completedLessons / totalLessons * 100).round()
              : 0,
        });
      }
    }

    final order = {'viewed': 0, 'late': 1, 'absent': 2};
    studentList.sort(
        (a, b) => (order[a['status']] ?? 3).compareTo(order[b['status']] ?? 3));

    return Response.json(body: {
      'classId': classId,
      'lessonId': lessonId,
      'total': studentList.length,
      'viewed': viewedCount,
      'late': lateCount,
      'absent': absentCount,
      'students': studentList,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi tải danh sách sinh viên: $e'},
    );
  }
}
