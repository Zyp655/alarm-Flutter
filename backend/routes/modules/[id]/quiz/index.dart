import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final moduleId = int.tryParse(id);
  if (moduleId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'ID module không hợp lệ'},
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _getQuiz(context, moduleId);
    case HttpMethod.post:
      return _createQuiz(context, moduleId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getQuiz(RequestContext context, int moduleId) async {
  try {
    final db = context.read<AppDatabase>();

    final quizzes = await (db.select(db.quizzes)
          ..where((q) => q.moduleId.equals(moduleId))
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)])
          ..limit(1))
        .get();

    if (quizzes.isEmpty) {
      return Response.json(
        body: {
          'quiz': null,
          'questions': <Map<String, dynamic>>[],
          'message': 'Chưa có bài kiểm tra cho module này',
        },
      );
    }

    final quiz = quizzes.first;

    final questions = await (db.select(db.quizQuestions)
          ..where((q) => q.quizId.equals(quiz.id))
          ..orderBy([(q) => OrderingTerm.asc(q.orderIndex)]))
        .get();

    return Response.json(
      body: {
        'quiz': {
          'id': quiz.id,
          'moduleId': quiz.moduleId,
          'topic': quiz.topic,
          'difficulty': quiz.difficulty,
          'questionCount': quiz.questionCount,
          'createdAt': quiz.createdAt.toIso8601String(),
        },
        'questions': questions.map((q) {
          List<dynamic> optionsList;
          try {
            optionsList = jsonDecode(q.options) as List<dynamic>;
          } catch (_) {
            optionsList = [q.options];
          }
          return {
            'id': q.id,
            'question': q.question,
            'questionType': q.questionType,
            'options': optionsList,
            'correctIndex': q.correctIndex,
            'correctAnswer': q.correctAnswer,
            'explanation': q.explanation,
          };
        }).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi khi tải bài kiểm tra: $e'},
    );
  }
}

Future<Response> _createQuiz(RequestContext context, int moduleId) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;

    final topic = body['topic'] as String? ?? 'Bài kiểm tra';
    final difficulty = body['difficulty'] as String? ?? 'medium';
    final questions = body['questions'] as List<dynamic>? ?? [];
    final createdBy = body['createdBy'] as int? ?? 0;

    final quiz = await db.into(db.quizzes).insertReturning(
          QuizzesCompanion.insert(
            createdBy: createdBy,
            moduleId: Value(moduleId),
            topic: topic,
            difficulty: difficulty,
            questionCount: questions.length,
            createdAt: DateTime.now(),
          ),
        );

    for (var i = 0; i < questions.length; i++) {
      final q = questions[i] as Map<String, dynamic>;
      final options = q['options'] as List<dynamic>? ?? [];
      await db.into(db.quizQuestions).insert(
            QuizQuestionsCompanion.insert(
              quizId: quiz.id,
              question: q['question'] as String? ?? '',
              options: jsonEncode(options),
              correctIndex: Value(q['correctIndex'] as int?),
              correctAnswer: Value(q['correctAnswer'] as String?),
              explanation: Value(q['explanation'] as String?),
              orderIndex: i,
            ),
          );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'message': 'Tạo bài kiểm tra thành công',
        'quizId': quiz.id,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Lỗi khi tạo bài kiểm tra: $e'},
    );
  }
}
