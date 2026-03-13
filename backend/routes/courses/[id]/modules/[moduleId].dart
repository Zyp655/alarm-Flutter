import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id, String moduleId) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final courseId = int.tryParse(id);
  final modId = int.tryParse(moduleId);

  if (courseId == null || modId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid ID'},
    );
  }

  try {
    final db = context.read<AppDatabase>();

    final module = await (db.select(db.modules)
          ..where((m) => m.id.equals(modId)))
        .getSingleOrNull();

    if (module == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Module not found'},
      );
    }

    final belongsToCourse =
        module.courseId == courseId || module.academicCourseId == courseId;
    if (!belongsToCourse) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Module not found'},
      );
    }

    await db.transaction(() async {
      final lessons = await (db.select(db.lessons)
            ..where((l) => l.moduleId.equals(modId)))
          .get();
      final lessonIds = lessons.map((l) => l.id).toList();

      if (lessonIds.isNotEmpty) {
        await (db.delete(db.lessonProgress)
              ..where((p) => p.lessonId.isIn(lessonIds)))
            .go();

        await (db.delete(db.learningActivities)
              ..where((a) => a.lessonId.isIn(lessonIds)))
            .go();

        await (db.delete(db.comments)
              ..where((c) => c.lessonId.isIn(lessonIds)))
            .go();

        await (db.delete(db.courseFiles)
              ..where((f) => f.lessonId.isIn(lessonIds)))
            .go();

        await (db.delete(db.scheduledLessons)
              ..where((s) => s.lessonId.isIn(lessonIds)))
            .go();

        await db.customStatement(
          'UPDATE roadmap_nodes SET lesson_id = NULL WHERE lesson_id IN (${lessonIds.join(",")})',
        );
        await db.customStatement(
          'UPDATE student_activity_logs SET lesson_id = NULL WHERE lesson_id IN (${lessonIds.join(",")})',
        );
      }

      final quizzes = await (db.select(db.quizzes)
            ..where((q) => q.moduleId.equals(modId)))
          .get();
      final quizIds = quizzes.map((q) => q.id).toList();

      if (quizIds.isNotEmpty) {
        await (db.delete(db.quizAttempts)
              ..where((a) => a.quizId.isIn(quizIds)))
            .go();
        await (db.delete(db.quizQuestions)
              ..where((q) => q.quizId.isIn(quizIds)))
            .go();
      }

      await (db.delete(db.lessons)
            ..where((l) => l.moduleId.equals(modId)))
          .go();

      await (db.delete(db.quizzes)
            ..where((q) => q.moduleId.equals(modId)))
          .go();

      await (db.delete(db.modules)
            ..where((m) => m.id.equals(modId)))
          .go();

      final isAcademic = module.academicCourseId == courseId;
      final remainingModules = await (db.select(db.modules)
            ..where((m) => isAcademic
                ? m.academicCourseId.equals(courseId)
                : m.courseId.equals(courseId))
            ..orderBy([(m) => OrderingTerm(expression: m.orderIndex)]))
          .get();

      for (var i = 0; i < remainingModules.length; i++) {
        if (remainingModules[i].orderIndex != i) {
          await (db.update(db.modules)
                ..where((m) => m.id.equals(remainingModules[i].id)))
              .write(ModulesCompanion(orderIndex: Value(i)));
        }
      }
    });

    return Response.json(body: {'message': 'Module deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi: $e'},
    );
  }
}
