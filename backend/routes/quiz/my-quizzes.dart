import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }
  try {
    final db = context.read<AppDatabase>();
    final params = context.request.uri.queryParameters;
    final userId = int.tryParse(params['userId'] ?? '');
    if (userId == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'userId is required'}),
      );
    }
    final quizzes = await (db.select(db.quizzes)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    final quizList = quizzes.map((q) {
      return {
        'id': q.id,
        'topic': q.topic,
        'difficulty': q.difficulty,
        'questionCount': q.questionCount,
        'createdAt': q.createdAt.toIso8601String(),
        'isPublic': q.isPublic,
      };
    }).toList();
    return Response.json(
      body: {
        'success': true,
        'quizzes': quizList,
        'total': quizList.length,
      },
    );
  } catch (e) {
    print('My Quizzes Error: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': e.toString(),
      }),
    );
  }
}