import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final moduleId = int.tryParse(id);
  if (moduleId == null) {
    return Response(
        statusCode: HttpStatus.badRequest, body: 'Invalid Module ID');
  }
  final db = context.read<AppDatabase>();
  if (context.request.method == HttpMethod.get) {
    return _getModuleQuiz(db, moduleId);
  } else if (context.request.method == HttpMethod.post) {
    return _saveModuleQuiz(context, db, moduleId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getModuleQuiz(AppDatabase db, int moduleId) async {
  try {
    final quiz = await (db.select(db.quizzes)
          ..where((t) => t.moduleId.equals(moduleId)))
        .getSingleOrNull();
    if (quiz == null) {
      return Response.json(
          body: {'quiz': null, 'message': 'No quiz found for this module'});
    }
    final questions = await (db.select(db.quizQuestions)
          ..where((t) => t.quizId.equals(quiz.id))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final questionsList = questions
        .map((q) => {
              'id': q.id,
              'question': q.question,
              'questionType': q.questionType,
              'options': jsonDecode(q.options),
              'correctIndex': q.correctIndex,
              'correctAnswer': q.correctAnswer,
              'explanation': q.explanation,
            })
        .toList();
    return Response.json(body: {
      'quiz': {
        'id': quiz.id,
        'topic': quiz.topic,
        'difficulty': quiz.difficulty,
        'questionCount': quiz.questionCount,
        'createdAt': quiz.createdAt.toIso8601String(),
      },
      'questions': questionsList,
    });
  } catch (e) {
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: jsonEncode({'error': e.toString()}));
  }
}
Future<Response> _saveModuleQuiz(
    RequestContext context, AppDatabase db, int moduleId) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final questionsData = body['questions'] as List<dynamic>?;
    final topic = body['topic'] as String? ?? 'Quiz';
    final difficulty = body['difficulty'] as String? ?? 'medium';
    if (questionsData == null || questionsData.isEmpty) {
      return Response(
          statusCode: HttpStatus.badRequest,
          body: jsonEncode({'error': 'Questions are required'}));
    }
    final userId = context.read<int?>() ?? 1;
    final module = await (db.select(db.modules)
          ..where((t) => t.id.equals(moduleId)))
        .getSingleOrNull();
    if (module == null) {
      return Response(
          statusCode: HttpStatus.notFound,
          body: jsonEncode({'error': 'Module not found'}));
    }
    final existingQuiz = await (db.select(db.quizzes)
          ..where((t) => t.moduleId.equals(moduleId)))
        .getSingleOrNull();
    if (existingQuiz != null) {
      await (db.delete(db.quizQuestions)
            ..where((t) => t.quizId.equals(existingQuiz.id)))
          .go();
      await (db.delete(db.quizzes)..where((t) => t.id.equals(existingQuiz.id)))
          .go();
    }
    final quizId = await db.into(db.quizzes).insert(
          QuizzesCompanion.insert(
            createdBy: userId,
            moduleId: Value(moduleId),
            topic: topic,
            difficulty: difficulty,
            subjectContext: const Value(null),
            questionCount: questionsData.length,
            createdAt: DateTime.now(),
          ),
        );
    for (int i = 0; i < questionsData.length; i++) {
      final q = questionsData[i] as Map<String, dynamic>;
      await db.into(db.quizQuestions).insert(
            QuizQuestionsCompanion.insert(
              quizId: quizId,
              question: q['question'] as String,
              options: jsonEncode(q['options']),
              correctIndex: Value(q['correctIndex'] as int?),
              correctAnswer: Value(q['correctAnswer'] as String?),
              explanation: Value(q['explanation'] as String?),
              orderIndex: i,
            ),
          );
    }
    return Response.json(body: {
      'success': true,
      'quizId': quizId,
      'message': 'Quiz saved successfully',
    });
  } catch (e) {
    return Response(
        statusCode: HttpStatus.internalServerError,
        body: jsonEncode({'error': e.toString()}));
  }
}