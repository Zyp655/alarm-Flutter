import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final roadmapId = int.tryParse(id);
  if (roadmapId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid roadmap ID'},
    );
  }
  final request = context.request;
  final method = request.method;
  if (method == HttpMethod.get) {
    return _getRoadmapDetails(context, roadmapId);
  } else if (method == HttpMethod.put) {
    return _updateRoadmap(context, roadmapId);
  } else if (method == HttpMethod.delete) {
    return _deleteRoadmap(context, roadmapId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getRoadmapDetails(
    RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final roadmap = await (db.select(db.roadmaps)
          ..where((r) => r.id.equals(roadmapId)))
        .getSingleOrNull();
    if (roadmap == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Roadmap not found'},
      );
    }
    final nodes = await (db.select(db.roadmapNodes)
          ..where((n) => n.roadmapId.equals(roadmapId)))
        .get();
    final edges = await (db.select(db.roadmapEdges)
          ..where((e) => e.roadmapId.equals(roadmapId)))
        .get();
    return Response.json(
      body: {
        'id': roadmap.id,
        'title': roadmap.title,
        'description': roadmap.description,
        'courseId': roadmap.courseId,
        'createdBy': roadmap.createdBy,
        'isPublished': roadmap.isPublished,
        'createdAt': roadmap.createdAt.toIso8601String(),
        'nodes': nodes
            .map((n) => {
                  'id': n.id,
                  'title': n.title,
                  'description': n.description,
                  'nodeType': n.nodeType,
                  'lessonId': n.lessonId,
                  'positionX': n.positionX,
                  'positionY': n.positionY,
                  'icon': n.icon,
                  'color': n.color,
                })
            .toList(),
        'edges': edges
            .map((e) => {
                  'id': e.id,
                  'fromNodeId': e.fromNodeId,
                  'toNodeId': e.toNodeId,
                  'edgeType': e.edgeType,
                })
            .toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch roadmap: $e'},
    );
  }
}
Future<Response> _updateRoadmap(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final title = body['title'] as String?;
    final description = body['description'] as String?;
    final isPublished = body['isPublished'] as bool?;
    await (db.update(db.roadmaps)..where((r) => r.id.equals(roadmapId))).write(
      RoadmapsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        isPublished:
            isPublished != null ? Value(isPublished) : const Value.absent(),
      ),
    );
    return Response.json(body: {'message': 'Roadmap updated successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update roadmap: $e'},
    );
  }
}
Future<Response> _deleteRoadmap(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    await (db.delete(db.roadmapEdges)
          ..where((e) => e.roadmapId.equals(roadmapId)))
        .go();
    await (db.delete(db.roadmapNodes)
          ..where((n) => n.roadmapId.equals(roadmapId)))
        .go();
    await (db.delete(db.roadmaps)..where((r) => r.id.equals(roadmapId))).go();
    return Response.json(body: {'message': 'Roadmap deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete roadmap: $e'},
    );
  }
}