import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';


Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  if (method == HttpMethod.get) {
    return _getLessons(context);
  } else if (method == HttpMethod.post) {
    return _createLesson(context);
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _getLessons(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final moduleIdStr = params['moduleId'];

    if (moduleIdStr == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'moduleId is required'},
      );
    }

    final moduleId = int.tryParse(moduleIdStr);
    if (moduleId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid moduleId'},
      );
    }

    final lessons = await (db.select(db.lessons)
          ..where((tbl) => tbl.moduleId.equals(moduleId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
        .get();

    return Response.json(
      body: lessons
          .map((l) => {
                'id': l.id,
                'moduleId': l.moduleId,
                'title': l.title,
                'type': l.type,
                'contentUrl': l.contentUrl,
                'durationMinutes': l.durationMinutes,
                'isFreePreview': l.isFreePreview,
                'orderIndex': l.orderIndex,
              })
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch lessons: $e'},
    );
  }
}

Future<Response> _createLesson(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final moduleId = body['moduleId'] as int?;
    final title = body['title'] as String?;
    final type = body['type'] as String? ?? 'video';

    if (moduleId == null || title == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'moduleId and title are required'},
      );
    }

    final existingLessons = await (db.select(db.lessons)
          ..where((tbl) => tbl.moduleId.equals(moduleId)))
        .get();
    final nextOrder = existingLessons.length;

    final lessonId = await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            moduleId: moduleId,
            title: title,
            type: type,
            contentUrl: Value(body['contentUrl'] as String?),
            textContent: Value(body['textContent'] as String?),
            durationMinutes: Value(body['durationMinutes'] as int? ?? 0),
            isFreePreview: Value(body['isFreePreview'] as bool? ?? false),
            orderIndex: nextOrder,
            createdAt: DateTime.now(),
          ),
        );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': lessonId,
        'message': 'Lesson created successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create lesson: $e'},
    );
  }
}
