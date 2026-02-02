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
  if (method == HttpMethod.post) {
    return _createEdge(context, roadmapId);
  } else if (method == HttpMethod.delete) {
    return _deleteEdge(context, roadmapId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _createEdge(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final fromNodeId = body['fromNodeId'] as int?;
    final toNodeId = body['toNodeId'] as int?;
    final edgeType = body['edgeType'] as String? ?? 'required';
    if (fromNodeId == null || toNodeId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'fromNodeId and toNodeId are required'},
      );
    }
    final edgeId = await db.into(db.roadmapEdges).insert(
          RoadmapEdgesCompanion.insert(
            roadmapId: roadmapId,
            fromNodeId: fromNodeId,
            toNodeId: toNodeId,
            edgeType: Value(edgeType),
          ),
        );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': edgeId, 'message': 'Edge created successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create edge: $e'},
    );
  }
}
Future<Response> _deleteEdge(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final edgeIdStr = params['edgeId'];
    if (edgeIdStr == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'edgeId query param is required'},
      );
    }
    final edgeId = int.tryParse(edgeIdStr);
    if (edgeId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid edgeId'},
      );
    }
    await (db.delete(db.roadmapEdges)
          ..where((e) => e.id.equals(edgeId) & e.roadmapId.equals(roadmapId)))
        .go();
    return Response.json(body: {'message': 'Edge deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete edge: $e'},
    );
  }
}