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
    return _createNode(context, roadmapId);
  } else if (method == HttpMethod.put) {
    return _updateNode(context, roadmapId);
  } else if (method == HttpMethod.delete) {
    return _deleteNode(context, roadmapId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _createNode(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final title = body['title'] as String?;
    final description = body['description'] as String?;
    final nodeType = body['nodeType'] as String? ?? 'milestone';
    final lessonId = body['lessonId'] as int?;
    final positionX = (body['positionX'] as num?)?.toDouble() ?? 0.0;
    final positionY = (body['positionY'] as num?)?.toDouble() ?? 0.0;
    final icon = body['icon'] as String?;
    final color = body['color'] as String?;
    if (title == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'title is required'},
      );
    }
    final nodeId = await db.into(db.roadmapNodes).insert(
          RoadmapNodesCompanion.insert(
            roadmapId: roadmapId,
            title: title,
            description: Value(description),
            nodeType: nodeType,
            lessonId: Value(lessonId),
            positionX: positionX,
            positionY: positionY,
            icon: Value(icon),
            color: Value(color),
          ),
        );
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': nodeId, 'message': 'Node created successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create node: $e'},
    );
  }
}
Future<Response> _updateNode(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final nodeId = body['nodeId'] as int?;
    if (nodeId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'nodeId is required'},
      );
    }
    final title = body['title'] as String?;
    final description = body['description'] as String?;
    final nodeType = body['nodeType'] as String?;
    final positionX = (body['positionX'] as num?)?.toDouble();
    final positionY = (body['positionY'] as num?)?.toDouble();
    final icon = body['icon'] as String?;
    final color = body['color'] as String?;
    await (db.update(db.roadmapNodes)
          ..where((n) => n.id.equals(nodeId) & n.roadmapId.equals(roadmapId)))
        .write(
      RoadmapNodesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        nodeType: nodeType != null ? Value(nodeType) : const Value.absent(),
        positionX: positionX != null ? Value(positionX) : const Value.absent(),
        positionY: positionY != null ? Value(positionY) : const Value.absent(),
        icon: icon != null ? Value(icon) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
      ),
    );
    return Response.json(body: {'message': 'Node updated successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update node: $e'},
    );
  }
}
Future<Response> _deleteNode(RequestContext context, int roadmapId) async {
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final nodeIdStr = params['nodeId'];
    if (nodeIdStr == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'nodeId query param is required'},
      );
    }
    final nodeId = int.tryParse(nodeIdStr);
    if (nodeId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Invalid nodeId'},
      );
    }
    await (db.delete(db.roadmapEdges)
          ..where(
              (e) => e.fromNodeId.equals(nodeId) | e.toNodeId.equals(nodeId)))
        .go();
    await (db.delete(db.roadmapNodes)
          ..where((n) => n.id.equals(nodeId) & n.roadmapId.equals(roadmapId)))
        .go();
    return Response.json(body: {'message': 'Node deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete node: $e'},
    );
  }
}