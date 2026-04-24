import 'dart:convert';
import 'dart:io';

import 'package:backend/database/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return _handleRegister(context);
  }
  if (context.request.method == HttpMethod.get) {
    return _handleStatus(context);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _handleRegister(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final userId = body['userId'] as int?;

    if (userId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId is required'},
      );
    }

    final frontEmbedding = body['frontEmbedding'] as List<dynamic>?;
    final leftEmbedding = body['leftEmbedding'] as List<dynamic>?;
    final rightEmbedding = body['rightEmbedding'] as List<dynamic>?;

    if (frontEmbedding == null || leftEmbedding == null || rightEmbedding == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'All 3 embeddings (front, left, right) are required'},
      );
    }

    final db = context.read<AppDatabase>();

    final existing = await (db.select(db.faceEmbeddings)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.faceEmbeddings)
            ..where((t) => t.userId.equals(userId)))
          .write(
        FaceEmbeddingsCompanion(
          frontData: Value(jsonEncode(frontEmbedding)),
          leftData: Value(jsonEncode(leftEmbedding)),
          rightData: Value(jsonEncode(rightEmbedding)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await db.into(db.faceEmbeddings).insert(
        FaceEmbeddingsCompanion.insert(
          userId: userId,
          frontData: jsonEncode(frontEmbedding),
          leftData: jsonEncode(leftEmbedding),
          rightData: jsonEncode(rightEmbedding),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return Response.json(body: {'success': true});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to register face: $e'},
    );
  }
}

Future<Response> _handleStatus(RequestContext context) async {
  try {
    final userId = int.tryParse(
      context.request.uri.queryParameters['userId'] ?? '',
    );

    if (userId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId query parameter is required'},
      );
    }

    final db = context.read<AppDatabase>();

    final record = await (db.select(db.faceEmbeddings)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (record == null) {
      return Response.json(body: {
        'registered': false,
      });
    }

    return Response.json(body: {
      'registered': true,
      'registeredAt': record.createdAt.toIso8601String(),
      'updatedAt': record.updatedAt.toIso8601String(),
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to check face status: $e'},
    );
  }
}
