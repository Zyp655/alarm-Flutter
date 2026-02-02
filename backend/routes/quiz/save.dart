import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:backend/database/database.dart';
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(
      statusCode: HttpStatus.methodNotAllowed,
      body: jsonEncode({'error': 'Method not allowed'}),
    );
  }
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final userId = data['userId'] as int?;
    final quiz = data['quiz'] as Map<String, dynamic>?;
    final isPublic = data['isPublic'] as bool? ?? false;
    if (userId == null || quiz == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'userId and quiz are required'}),
      );
    }
    final topic = quiz['topic'] as String;
    final difficulty = quiz['difficulty'] as String;
    final questions = quiz['questions'] as List;
    final subjectContext = quiz['subjectContext'] as String?;
    final quizId = await db.into(db.quizzes).insert(
          QuizzesCompanion.insert(
            createdBy: userId,
            topic: topic,
            difficulty: difficulty,
            subjectContext: Value(subjectContext),
            questionCount: questions.length,
            createdAt: DateTime.now(),
            isPublic: Value(isPublic),
          ),
        );
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i] as Map<String, dynamic>;
      await db.into(db.quizQuestions).insert(
            QuizQuestionsCompanion.insert(
              quizId: quizId,
              questionType:
                  Value(q['questionType'] as String? ?? 'multiple_choice'),
              question: q['question'] as String,
              options: jsonEncode(q['options']),
              correctIndex: Value(q['correctIndex'] as int?),
              correctAnswer: Value(q['correctAnswer'] as String?),
              explanation: Value(q['explanation'] as String?),
              orderIndex: i,
            ),
          );
    }
    return Response.json(
      body: {
        'success': true,
        'quizId': quizId,
        'message': 'Quiz saved successfully',
      },
    );
  } catch (e) {
    print('Save Quiz Error: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': e.toString(),
      }),
    );
  }
}