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
      body: {'error': 'Failed to fetch lesson: $e'},
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
      body: {'error': 'Failed to update lesson: $e'},
    );
  }
}

Future<Response> _deleteLesson(RequestContext context, int lessonId) async {
  try {
    final db = context.read<AppDatabase>();

    await (db.delete(db.lessonProgress)
          ..where((tbl) => tbl.lessonId.equals(lessonId)))
        .go();

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
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete lesson: $e'},
    );
  }
}
