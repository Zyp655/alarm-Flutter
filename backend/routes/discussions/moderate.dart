import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final commentId = body['commentId'] as int?;
    final action = body['action'] as String?;

    if (commentId == null || action == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'commentId and action are required'},
      );
    }

    switch (action) {
      case 'pin':
        await (db.update(db.comments)..where((t) => t.id.equals(commentId)))
            .write(const CommentsCompanion(isPinned: Value(true)));
        return Response.json(body: {'message': 'Comment pinned'});

      case 'unpin':
        await (db.update(db.comments)..where((t) => t.id.equals(commentId)))
            .write(const CommentsCompanion(isPinned: Value(false)));
        return Response.json(body: {'message': 'Comment unpinned'});

      case 'answer':
        await (db.update(db.comments)..where((t) => t.id.equals(commentId)))
            .write(const CommentsCompanion(isAnswered: Value(true)));
        return Response.json(body: {'message': 'Marked as answer'});

      case 'unanswer':
        await (db.update(db.comments)..where((t) => t.id.equals(commentId)))
            .write(const CommentsCompanion(isAnswered: Value(false)));
        return Response.json(body: {'message': 'Unmarked as answer'});

      default:
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Invalid action: $action'},
        );
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to moderate: $e'},
    );
  }
}
