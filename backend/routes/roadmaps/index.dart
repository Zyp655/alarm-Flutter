import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;
  if (method == HttpMethod.get) {
    return _getRoadmaps(context);
  } else if (method == HttpMethod.post) {
    return _createRoadmap(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getRoadmaps(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final courseIdStr = params['courseId'];
    final createdByStr = params['createdBy'];
    var query = db.select(db.roadmaps);
    if (courseIdStr != null) {
      final courseId = int.tryParse(courseIdStr);
      if (courseId != null) {
        query = query..where((r) => r.courseId.equals(courseId));
      }
    }
    if (createdByStr != null) {
      final createdBy = int.tryParse(createdByStr);
      if (createdBy != null) {
        query = query..where((r) => r.createdBy.equals(createdBy));
      }
    }
    final roadmaps = await query.get();
    return Response.json(
      body: roadmaps
          .map((r) => {
                'id': r.id,
                'title': r.title,
                'description': r.description,
                'courseId': r.courseId,
                'createdBy': r.createdBy,
                'isPublished': r.isPublished,
                'createdAt': r.createdAt.toIso8601String(),
              })
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch roadmaps: $e'},
    );
  }
}
Future<Response> _createRoadmap(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final title = body['title'] as String?;
    final description = body['description'] as String?;
    final courseId = body['courseId'] as int?;
    final createdBy = body['createdBy'] as int?;
    if (title == null || createdBy == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'title and createdBy are required'},
      );
    }
    final id = await db.into(db.roadmaps).insert(
          RoadmapsCompanion.insert(
            title: title,
            description: Value(description),
            courseId: Value(courseId),
            createdBy: createdBy,
            createdAt: DateTime.now(),
          ),
        );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'message': 'Roadmap created successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create roadmap: $e'},
    );
  }
}