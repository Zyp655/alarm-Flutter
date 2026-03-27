import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';

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
    case HttpMethod.put:
      return _updateQuiz(db, quizId, context);
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
      body: jsonEncode({'success': false, 'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'}),
    );
  }
}

Future<Response> _updateQuiz(AppDatabase db, int quizId, RequestContext context) async {
  try {
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final quiz = await (db.select(db.quizzes)
          ..where((t) => t.id.equals(quizId)))
        .getSingleOrNull();
    if (quiz == null) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Quiz not found'}),
      );
    }

    final topic = data['topic'] as String? ?? quiz.topic;
    final difficulty = data['difficulty'] as String? ?? quiz.difficulty;
    final questions = data['questions'] as List?;

    await (db.update(db.quizzes)..where((t) => t.id.equals(quizId))).write(
      QuizzesCompanion(
        topic: Value(topic),
        difficulty: Value(difficulty),
        questionCount: Value(questions?.length ?? quiz.questionCount),
      ),
    );

    if (questions != null) {
      await (db.delete(db.quizQuestions)
            ..where((t) => t.quizId.equals(quizId)))
          .go();

      for (var i = 0; i < questions.length; i++) {
        final q = questions[i] as Map<String, dynamic>;
        await db.into(db.quizQuestions).insert(
              QuizQuestionsCompanion.insert(
                quizId: quizId,
                questionType: Value(q['questionType'] as String? ?? 'multiple_choice'),
                question: q['question'] as String,
                options: jsonEncode(q['options']),
                correctIndex: Value(q['correctIndex'] as int?),
                correctAnswer: Value(q['correctAnswer'] as String?),
                explanation: Value(q['explanation'] as String?),
                orderIndex: i,
              ),
            );
      }
    }

    return Response.json(
      body: {
        'success': true,
        'message': 'Quiz updated successfully',
      },
    );
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({'success': false, 'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'}),
    );
  }
}

Future<Response> _deleteQuiz(AppDatabase db, int quizId) async {
  try {
    await (db.delete(db.quizAttempts)..where((t) => t.quizId.equals(quizId)))
        .go();
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
      body: jsonEncode({'success': false, 'error': 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.'}),
    );
  }
}
