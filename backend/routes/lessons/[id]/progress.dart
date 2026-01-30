import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final method = request.method;
  final lessonId = int.tryParse(id);

  if (lessonId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid lesson ID'},
    );
  }

  if (method == HttpMethod.post) {
    return _updateProgress(context, lessonId);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _updateProgress(RequestContext context, int lessonId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    if (!body.containsKey('userId')) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId is required'},
      );
    }

    final userId = body['userId'] as int;
    final lastWatchedPosition = body['lastWatchedPosition'] as int? ?? 0;
    final isCompleted = body['isCompleted'] as bool? ?? false;

    final existing = await (db.select(db.lessonProgress)
          ..where((tbl) =>
              tbl.userId.equals(userId) & tbl.lessonId.equals(lessonId)))
        .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.lessonProgress)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        LessonProgressCompanion(
          lastWatchedPosition: Value(lastWatchedPosition),
          isCompleted: Value(isCompleted),
          completedAt:
              isCompleted ? Value(DateTime.now()) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await db.into(db.lessonProgress).insert(
            LessonProgressCompanion.insert(
              userId: userId,
              lessonId: lessonId,
              lastWatchedPosition: Value(lastWatchedPosition),
              isCompleted: Value(isCompleted),
              completedAt:
                  isCompleted ? Value(DateTime.now()) : const Value.absent(),
              updatedAt: DateTime.now(),
            ),
          );
    }

    if (isCompleted) {
      await _updateEnrollmentProgress(db, userId, lessonId);
    }

    return Response.json(body: {
      'message': 'Progress updated successfully',
      'isCompleted': isCompleted,
      'lastWatchedPosition': lastWatchedPosition,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update progress: $e'},
    );
  }
}

Future<void> _updateEnrollmentProgress(
    AppDatabase db, int userId, int lessonId) async {
  final lesson = await (db.select(db.lessons)
        ..where((tbl) => tbl.id.equals(lessonId)))
      .getSingle();

  final module = await (db.select(db.modules)
        ..where((tbl) => tbl.id.equals(lesson.moduleId)))
      .getSingle();

  final courseId = module.courseId;

  final allModules = await (db.select(db.modules)
        ..where((tbl) => tbl.courseId.equals(courseId)))
      .get();

  var totalLessons = 0;
  for (final mod in allModules) {
    final lessonCount = await (db.select(db.lessons)
          ..where((tbl) => tbl.moduleId.equals(mod.id)))
        .get();
    totalLessons += lessonCount.length;
  }

  var completedCount = 0;
  for (final mod in allModules) {
    final moduleLessons = await (db.select(db.lessons)
          ..where((tbl) => tbl.moduleId.equals(mod.id)))
        .get();

    for (final l in moduleLessons) {
      final progress = await (db.select(db.lessonProgress)
            ..where((tbl) =>
                tbl.userId.equals(userId) &
                tbl.lessonId.equals(l.id) &
                tbl.isCompleted.equals(true)))
          .getSingleOrNull();

      if (progress != null) {
        completedCount++;
      }
    }
  }

  final progressPercent =
      totalLessons > 0 ? (completedCount / totalLessons) * 100 : 0.0;

  final enrollment = await (db.select(db.enrollments)
        ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.courseId.equals(courseId)))
      .getSingleOrNull();

  if (enrollment != null) {
    await (db.update(db.enrollments)
          ..where((tbl) => tbl.id.equals(enrollment.id)))
        .write(
      EnrollmentsCompanion(
        progressPercent: Value(progressPercent),
        completedAt: progressPercent >= 100.0
            ? Value(DateTime.now())
            : const Value.absent(),
        lastAccessedAt: Value(DateTime.now()),
      ),
    );
  }
}
