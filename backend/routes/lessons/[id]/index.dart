import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
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
  if (method == HttpMethod.get) {
    return _getLesson(context, lessonId);
  } else if (method == HttpMethod.put) {
    return _updateLesson(context, lessonId);
  } else if (method == HttpMethod.delete) {
    return _deleteLesson(context, lessonId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getLesson(RequestContext context, int lessonId) async {
  try {
    final db = context.read<AppDatabase>();
    final lesson = await (db.select(db.lessons)
          ..where((tbl) => tbl.id.equals(lessonId)))
        .getSingleOrNull();
    if (lesson == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Lesson not found'},
      );
    }
    return Response.json(body: {
      'id': lesson.id,
      'moduleId': lesson.moduleId,
      'title': lesson.title,
      'type': lesson.type,
      'contentUrl': lesson.contentUrl,
      'textContent': lesson.textContent,
      'durationMinutes': lesson.durationMinutes,
      'isFreePreview': lesson.isFreePreview,
      'orderIndex': lesson.orderIndex,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
Future<Response> _updateLesson(RequestContext context, int lessonId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final count = await (db.update(db.lessons)
          ..where((tbl) => tbl.id.equals(lessonId)))
        .write(
      LessonsCompanion(
        title: body.containsKey('title')
            ? Value(body['title'] as String)
            : const Value.absent(),
        type: body.containsKey('type')
            ? Value(body['type'] as String)
            : const Value.absent(),
        contentUrl: body.containsKey('contentUrl')
            ? Value(body['contentUrl'] as String?)
            : const Value.absent(),
        textContent: body.containsKey('textContent')
            ? Value(body['textContent'] as String?)
            : const Value.absent(),
        durationMinutes: body.containsKey('durationMinutes')
            ? Value(body['durationMinutes'] as int)
            : const Value.absent(),
        isFreePreview: body.containsKey('isFreePreview')
            ? Value(body['isFreePreview'] as bool)
            : const Value.absent(),
        orderIndex: body.containsKey('orderIndex')
            ? Value(body['orderIndex'] as int)
            : const Value.absent(),
      ),
    );
    if (count == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Lesson not found'},
      );
    }
    return Response.json(body: {'message': 'Lesson updated successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'},
    );
  }
}
Future<Response> _deleteLesson(RequestContext context, int lessonId) async {
  try {
    final db = context.read<AppDatabase>();

    final segmentIds = await (db.select(db.videoSegments)
          ..where((s) => s.lessonId.equals(lessonId)))
        .get();
    for (final seg in segmentIds) {
      await (db.delete(db.segmentQuizAttempts)
            ..where((a) => a.segmentId.equals(seg.id)))
          .go();
    }
    await (db.delete(db.videoSegments)
          ..where((s) => s.lessonId.equals(lessonId)))
        .go();

    final commentIds = await (db.select(db.comments)
          ..where((c) => c.lessonId.equals(lessonId)))
        .get();
    for (final comment in commentIds) {
      await (db.delete(db.commentVotes)
            ..where((v) => v.commentId.equals(comment.id)))
          .go();
      await (db.delete(db.commentMentions)
            ..where((m) => m.commentId.equals(comment.id)))
          .go();
    }
    await (db.delete(db.comments)
          ..where((c) => c.lessonId.equals(lessonId)))
        .go();

    final nodeIds = await (db.select(db.roadmapNodes)
          ..where((n) => n.lessonId.equals(lessonId)))
        .get();
    for (final node in nodeIds) {
      await (db.delete(db.roadmapEdges)
            ..where((e) =>
                e.fromNodeId.equals(node.id) | e.toNodeId.equals(node.id)))
          .go();
    }
    await (db.update(db.roadmapNodes)
          ..where((n) => n.lessonId.equals(lessonId)))
        .write(const RoadmapNodesCompanion(lessonId: Value(null)));

    await (db.delete(db.courseFiles)
          ..where((f) => f.lessonId.equals(lessonId)))
        .go();
    await (db.delete(db.scheduledLessons)
          ..where((s) => s.lessonId.equals(lessonId)))
        .go();
    await (db.delete(db.confusionLogs)
          ..where((c) => c.lessonId.equals(lessonId)))
        .go();
    await (db.delete(db.lessonProgress)
          ..where((p) => p.lessonId.equals(lessonId)))
        .go();

    await (db.update(db.learningActivities)
          ..where((a) => a.lessonId.equals(lessonId)))
        .write(const LearningActivitiesCompanion(lessonId: Value(null)));
    await (db.update(db.studentActivityLogs)
          ..where((a) => a.lessonId.equals(lessonId)))
        .write(const StudentActivityLogsCompanion(lessonId: Value(null)));

    final count = await (db.delete(db.lessons)
          ..where((tbl) => tbl.id.equals(lessonId)))
        .go();
    if (count == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Lesson not found'},
      );
    }
    return Response.json(body: {'message': 'Lesson deleted successfully'});
  } catch (e) {
    print('[Lessons] Delete error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Không thể xóa bài học: $e'},
    );
  }
}
