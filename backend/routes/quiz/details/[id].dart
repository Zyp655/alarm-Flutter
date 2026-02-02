import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import '../../../lib/database/database.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final db = context.read<AppDatabase>();
  final quizId = int.tryParse(id);
  if (quizId == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: jsonEncode({'error': 'Invalid quiz ID'}),
    );
  }
  switch (context.request.method) {
    case HttpMethod.get:
      return _getQuiz(db, quizId);
    case HttpMethod.delete:
      return _deleteQuiz(db, quizId);
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: jsonEncode({'error': 'Method not allowed'}),
      );
  }
}
Future<Response> _getQuiz(AppDatabase db, int quizId) async {
  try {
    final quiz = await (db.select(db.quizzes)
          ..where((t) => t.id.equals(quizId)))
        .getSingleOrNull();
    if (quiz == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Quiz not found'}),
      );
    }
    final questions = await (db.select(db.quizQuestions)
          ..where((t) => t.quizId.equals(quizId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final questionList = questions.map((q) {
      return {
        'id': q.id,
        'questionType': q.questionType,
        'question': q.question,
        'options': jsonDecode(q.options),
        'correctIndex': q.correctIndex,
        'correctAnswer': q.correctAnswer,
        'explanation': q.explanation,
      };
    }).toList();
    return Response.json(
      body: {
        'success': true,
        'quiz': {
          'id': quiz.id,
          'createdBy': quiz.createdBy,
          'topic': quiz.topic,
          'difficulty': quiz.difficulty,
          'subjectContext': quiz.subjectContext,
          'questionCount': quiz.questionCount,
          'createdAt': quiz.createdAt.toIso8601String(),
          'isPublic': quiz.isPublic,
          'questions': questionList,
        },
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': e.toString()}),
    );
  }
}
Future<Response> _deleteQuiz(AppDatabase db, int quizId) async {
  try {
    await (db.delete(db.quizQuestions)..where((t) => t.quizId.equals(quizId)))
        .go();
    final deleted =
        await (db.delete(db.quizzes)..where((t) => t.id.equals(quizId))).go();
    if (deleted == 0) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Quiz not found'}),
      );
    }
    return Response.json(
      body: {
        'success': true,
        'message': 'Quiz deleted successfully',
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': e.toString()}),
    );
  }
}