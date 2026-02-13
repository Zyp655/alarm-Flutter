import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

class CourseService {
  final AppDatabase db;
  CourseService(this.db);

  Future<Map<String, dynamic>> getCourseDetails(
    int courseId, {
    int? userId,
  }) async {
    Set<int> completedLessonIds = {};
    if (userId != null) {
      final progressRows = await (db.select(db.lessonProgress)
            ..where((tbl) =>
                tbl.userId.equals(userId) & tbl.isCompleted.equals(true)))
          .get();
      completedLessonIds = progressRows.map((row) => row.lessonId).toSet();
    }

    final course = await (db.select(db.courses)
          ..where((tbl) => tbl.id.equals(courseId)))
        .getSingleOrNull();
    if (course == null) {
      return {'error': 'Course not found', 'statusCode': 404};
    }

    final modules = await (db.select(db.modules)
          ..where((tbl) => tbl.courseId.equals(courseId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
        .get();

    final modulesWithLessons = <Map<String, dynamic>>[];
    int totalDuration = 0;

    for (final module in modules) {
      final lessons = await (db.select(db.lessons)
            ..where((tbl) => tbl.moduleId.equals(module.id))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
          .get();

      for (final lesson in lessons) {
        totalDuration += lesson.durationMinutes;
      }

      modulesWithLessons.add({
        'id': module.id,
        'title': module.title,
        'description': module.description,
        'orderIndex': module.orderIndex,
        'lessons': lessons
            .map((lesson) => {
                  'id': lesson.id,
                  'title': lesson.title,
                  'type': lesson.type,
                  'contentUrl': lesson.contentUrl,
                  'durationMinutes': lesson.durationMinutes,
                  'isFreePreview': lesson.isFreePreview,
                  'orderIndex': lesson.orderIndex,
                  'isCompleted': completedLessonIds.contains(lesson.id),
                })
            .toList(),
      });
    }

    final studentCount = await (db.select(db.enrollments)
          ..where((e) => e.courseId.equals(courseId)))
        .get()
        .then((rows) => rows.length);

    final reviews = await (db.select(db.courseReviews)
          ..where((r) => r.courseId.equals(courseId)))
        .get();
    double averageRating = 0;
    if (reviews.isNotEmpty) {
      final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
      averageRating = total / reviews.length;
    }

    return {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'thumbnailUrl': course.thumbnailUrl,
      'instructorId': course.instructorId,
      'price': course.price,
      'tags': course.tags,
      'level': course.level,
      'durationMinutes': totalDuration,
      'studentCount': studentCount,
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      'reviewsCount': reviews.length,
      'isPublished': course.isPublished,
      'modules': modulesWithLessons,
    };
  }

  Future<int> updateCourse(
    int courseId,
    Map<String, dynamic> body,
  ) async {
    final updated = db.update(db.courses)
      ..where((tbl) => tbl.id.equals(courseId));
    return updated.write(
      CoursesCompanion(
        title: body.containsKey('title')
            ? Value(body['title'] as String)
            : const Value.absent(),
        description: body.containsKey('description')
            ? Value(body['description'] as String?)
            : const Value.absent(),
        thumbnailUrl: body.containsKey('thumbnailUrl')
            ? Value(body['thumbnailUrl'] as String?)
            : const Value.absent(),
        price: body.containsKey('price')
            ? Value((body['price'] as num).toDouble())
            : const Value.absent(),
        tags: body.containsKey('tags')
            ? Value(body['tags'] as String?)
            : const Value.absent(),
        level: body.containsKey('level')
            ? Value(body['level'] as String)
            : const Value.absent(),
        durationMinutes: body.containsKey('durationMinutes')
            ? Value(body['durationMinutes'] as int)
            : const Value.absent(),
        isPublished: body.containsKey('isPublished')
            ? Value(body['isPublished'] as bool)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteCourse(int courseId) async {
    final course = await (db.select(db.courses)
          ..where((tbl) => tbl.id.equals(courseId)))
        .getSingleOrNull();
    if (course == null) {
      throw CourseNotFoundException(courseId);
    }

    final studyPlans = await (db.select(db.studyPlans)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .get();
    for (final plan in studyPlans) {
      await (db.delete(db.scheduledLessons)
            ..where((tbl) => tbl.studyPlanId.equals(plan.id)))
          .go();
    }
    await (db.delete(db.studyPlans)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .go();

    await (db.delete(db.studentActivityLogs)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .go();

    final roadmaps = await (db.select(db.roadmaps)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .get();
    for (final roadmap in roadmaps) {
      await (db.delete(db.roadmapEdges)
            ..where((tbl) => tbl.roadmapId.equals(roadmap.id)))
          .go();
      await (db.delete(db.roadmapNodes)
            ..where((tbl) => tbl.roadmapId.equals(roadmap.id)))
          .go();
    }
    await (db.delete(db.roadmaps)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .go();

    final modules = await (db.select(db.modules)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .get();

    for (final module in modules) {
      final lessons = await (db.select(db.lessons)
            ..where((tbl) => tbl.moduleId.equals(module.id)))
          .get();

      for (final lesson in lessons) {
        await (db.delete(db.lessonProgress)
              ..where((tbl) => tbl.lessonId.equals(lesson.id)))
            .go();
        await (db.delete(db.comments)
              ..where((tbl) => tbl.lessonId.equals(lesson.id)))
            .go();
        await (db.delete(db.courseFiles)
              ..where((tbl) => tbl.lessonId.equals(lesson.id)))
            .go();
        await (db.delete(db.roadmapNodes)
              ..where((tbl) => tbl.lessonId.equals(lesson.id)))
            .go();
        await (db.delete(db.scheduledLessons)
              ..where((tbl) => tbl.lessonId.equals(lesson.id)))
            .go();
        await (db.delete(db.studentActivityLogs)
              ..where((tbl) => tbl.lessonId.equals(lesson.id)))
            .go();
      }

      await (db.delete(db.lessons)
            ..where((tbl) => tbl.moduleId.equals(module.id)))
          .go();
    }

    await (db.delete(db.modules)..where((tbl) => tbl.courseId.equals(courseId)))
        .go();
    await (db.delete(db.enrollments)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .go();
    await (db.delete(db.courseReviews)
          ..where((tbl) => tbl.courseId.equals(courseId)))
        .go();
    await (db.delete(db.courses)..where((tbl) => tbl.id.equals(courseId))).go();
  }
}

class CourseNotFoundException implements Exception {
  final int courseId;
  CourseNotFoundException(this.courseId);

  @override
  String toString() => 'Course $courseId not found';
}
