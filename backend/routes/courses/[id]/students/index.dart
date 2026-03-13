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
    final statusFilter = params['status'];
    final progressFilter = params['progress'];
    final sortBy = params['sortBy'];
    final sortOrder = params['sortOrder'] ?? 'asc';
    final searchQuery = params['search']?.toLowerCase();
    final threshold = int.tryParse(params['threshold'] ?? '3') ?? 3;

    final lmsEnrollments = await (db.select(db.enrollments)
          ..where((e) => e.courseId.equals(courseId)))
        .get();

    final isAcademic = lmsEnrollments.isEmpty;
    List<int> enrolledUserIds = [];

    if (isAcademic) {
      final classes = await (db.select(db.courseClasses)
            ..where((c) => c.academicCourseId.equals(courseId)))
          .get();
      final classIds = classes.map((c) => c.id).toList();
      if (classIds.isNotEmpty) {
        final classEnrollments = await (db.select(db.courseClassEnrollments)
              ..where((e) => e.courseClassId.isIn(classIds)))
            .get();
        enrolledUserIds = classEnrollments.map((e) => e.studentId).toSet().toList();
      }
    }

    final modules = await (db.select(db.modules)
          ..where((m) => isAcademic
              ? m.academicCourseId.equals(courseId)
              : m.courseId.equals(courseId)))
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
    int statusNotStarted = 0;
    int statusInProgress = 0;
    int statusCompleted = 0;
    double totalProgressPercent = 0;
    double totalQuizScore = 0;
    int quizScoreCount = 0;

    final userIdsToProcess = isAcademic
        ? enrolledUserIds
        : lmsEnrollments.map((e) => e.userId).toList();

    for (final userId in userIdsToProcess) {
      final user = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .getSingleOrNull();
      if (user == null) continue;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final name = (user.fullName ?? '').toLowerCase();
        final email = user.email.toLowerCase();
        if (!name.contains(searchQuery) && !email.contains(searchQuery)) {
          continue;
        }
      }
      int completedLessons = 0;
      if (moduleIds.isNotEmpty) {
        final lessons = await (db.select(db.lessons)
              ..where((l) => l.moduleId.isIn(moduleIds)))
            .get();
        final lessonIds = lessons.map((l) => l.id).toList();
        if (lessonIds.isNotEmpty) {
          final progress = await (db.select(db.lessonProgress)
                ..where((p) => p.userId.equals(userId))
                ..where((p) => p.lessonId.isIn(lessonIds))
                ..where((p) => p.isCompleted.equals(true)))
              .get();
          completedLessons = progress.length;
        }
      }
      final progressPercent = totalLessons > 0
          ? (completedLessons / totalLessons * 100).round()
          : 0;
      if (progressFilter != null) {
        if (progressFilter == 'low' && progressPercent > 30) continue;
        if (progressFilter == 'medium' &&
            (progressPercent <= 30 || progressPercent > 70)) continue;
        if (progressFilter == 'high' && progressPercent <= 70) continue;
      }
      String status;
      if (completedLessons == 0) {
        status = 'not_started';
        statusNotStarted++;
      } else if (completedLessons >= totalLessons) {
        status = 'completed';
        statusCompleted++;
      } else {
        status = 'in_progress';
        statusInProgress++;
      }
      if (statusFilter != null && status != statusFilter) {
        continue;
      }
      totalProgressPercent += progressPercent;
      double? quizAverage;
      if (moduleIds.isNotEmpty) {
        final quizAttempts = await (db.select(db.quizAttempts)
              ..where((a) => a.userId.equals(userId)))
            .get();
        if (quizAttempts.isNotEmpty) {
          final quizzes = await (db.select(db.quizzes)
                ..where((q) => q.moduleId.isIn(moduleIds)))
              .get();
          final quizIds = quizzes.map((q) => q.id).toSet();
          final relevantAttempts =
              quizAttempts.where((a) => quizIds.contains(a.quizId)).toList();
          if (relevantAttempts.isNotEmpty) {
            final totalScore = relevantAttempts.fold<double>(
                0, (sum, a) => sum + a.scorePercentage);
            quizAverage = totalScore / relevantAttempts.length;
            totalQuizScore += quizAverage;
            quizScoreCount++;
          }
        }
      }

      DateTime? enrolledAt;
      DateTime? lastAccessedAt;
      if (!isAcademic) {
        final enrollment = lmsEnrollments.firstWhere((e) => e.userId == userId);
        enrolledAt = enrollment.enrolledAt;
        lastAccessedAt = enrollment.lastAccessedAt;
      }

      final lastActivity = await (db.select(db.studentActivityLogs)
            ..where((a) => a.userId.equals(userId))
            ..orderBy([(a) => OrderingTerm.desc(a.timestamp)])
            ..limit(1))
          .getSingleOrNull();
      int daysInactive = 0;
      bool isAtRisk = false;
      if (lastAccessedAt != null) {
        final now = DateTime.now();
        daysInactive = now.difference(lastAccessedAt).inDays;
        if (daysInactive >= threshold && status != 'completed') {
          isAtRisk = true;
        }
      } else if (!isAcademic) {
        isAtRisk = true;
        daysInactive = -1;
      }
      students.add({
        'userId': user.id,
        'email': user.email,
        'fullName': user.fullName ?? 'Unknown',
        'enrolledAt': enrolledAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'progressPercent': progressPercent,
        'status': status,
        'quizAverage': quizAverage,
        'lastAccessedAt': lastAccessedAt?.toIso8601String(),
        'lastNudgedAt': null,
        'daysInactive': daysInactive,
        'isAtRisk': isAtRisk,
        'lastActivity': lastActivity != null
            ? {
                'action': lastActivity.action,
                'timestamp': lastActivity.timestamp.toIso8601String(),
              }
            : null,
      });
    }
    if (sortBy != null) {
      students.sort((a, b) {
        dynamic valueA, valueB;
        switch (sortBy) {
          case 'name':
            valueA = a['fullName'] as String;
            valueB = b['fullName'] as String;
            break;
          case 'progress':
            valueA = a['progressPercent'] as int;
            valueB = b['progressPercent'] as int;
            break;
          case 'quizScore':
            valueA = a['quizAverage'] ?? 0.0;
            valueB = b['quizAverage'] ?? 0.0;
            break;
          case 'risk':
            valueA = (a['isAtRisk'] as bool) ? 1 : 0;
            valueB = (b['isAtRisk'] as bool) ? 1 : 0;
            break;
          default:
            return 0;
        }
        final comparison = (valueA as Comparable).compareTo(valueB);
        return sortOrder == 'desc' ? -comparison : comparison;
      });
    }
    final avgProgress = students.isNotEmpty
        ? (totalProgressPercent / students.length).round()
        : 0;
    final avgQuizScore = quizScoreCount > 0
        ? (totalQuizScore / quizScoreCount * 10).round() / 10
        : null;
    final atRiskCount = students.where((s) => s['isAtRisk'] as bool).length;
    return Response.json(
      body: {
        'courseId': courseId,
        'stats': {
          'totalStudents': students.length,
          'avgProgress': avgProgress,
          'avgQuizScore': avgQuizScore,
          'atRiskCount': atRiskCount,
          'byStatus': {
            'not_started': statusNotStarted,
            'in_progress': statusInProgress,
            'completed': statusCompleted,
          },
        },
        'students': students,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
