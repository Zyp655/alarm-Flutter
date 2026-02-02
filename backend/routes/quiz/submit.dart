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
    final quizId = data['quizId'] as int?;
    final answers = data['answers'] as List?;
    final timeSpentSeconds = data['timeSpentSeconds'] as int? ?? 0;
    if (userId == null || quizId == null || answers == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: jsonEncode({'error': 'userId, quizId, and answers are required'}),
      );
    }
    final questions = await (db.select(db.quizQuestions)
          ..where((t) => t.quizId.equals(quizId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    if (questions.isEmpty) {
      return Response(
        statusCode: HttpStatus.notFound,
        body: jsonEncode({'error': 'Quiz not found'}),
      );
    }
    int correctCount = 0;
    for (var i = 0; i < questions.length && i < answers.length; i++) {
      final q = questions[i];
      final userAnswer = answers[i];
      if (q.questionType == 'fill_blank') {
        if (q.correctAnswer != null &&
            userAnswer.toString().toLowerCase().trim() ==
                q.correctAnswer!.toLowerCase().trim()) {
          correctCount++;
        }
      } else {
        if (q.correctIndex != null && userAnswer == q.correctIndex) {
          correctCount++;
        }
      }
    }
    final totalQuestions = questions.length;
    final scorePercentage = (correctCount / totalQuestions) * 100;
    final attemptId = await db.into(db.quizAttempts).insert(
          QuizAttemptsCompanion.insert(
            quizId: quizId,
            userId: userId,
            correctCount: correctCount,
            totalQuestions: totalQuestions,
            scorePercentage: scorePercentage,
            timeSpentSeconds: timeSpentSeconds,
            answers: jsonEncode(answers),
            completedAt: DateTime.now(),
          ),
        );
    final quiz = await (db.select(db.quizzes)
          ..where((t) => t.id.equals(quizId)))
        .getSingleOrNull();
    if (quiz != null) {
      await _updateStatistics(
        db,
        userId,
        quiz.topic,
        correctCount,
        totalQuestions,
        scorePercentage,
      );
      await _updateLeaderboard(
          db,
          userId,
          (correctCount * 10)
              .toInt());
    }
    return Response.json(
      body: {
        'success': true,
        'attemptId': attemptId,
        'correctCount': correctCount,
        'totalQuestions': totalQuestions,
        'scorePercentage': scorePercentage,
        'passed': scorePercentage >= 50,
      },
    );
  } catch (e) {
    print('Submit Quiz Error: $e');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: jsonEncode({
        'success': false,
        'error': e.toString(),
      }),
    );
  }
}
Future<void> _updateStatistics(
  AppDatabase db,
  int userId,
  String topic,
  int correctCount,
  int totalQuestions,
  double scorePercentage,
) async {
  final existing = await (db.select(db.quizStatistics)
        ..where((t) => t.userId.equals(userId) & t.topic.equals(topic)))
      .getSingleOrNull();
  if (existing == null) {
    await db.into(db.quizStatistics).insert(
          QuizStatisticsCompanion.insert(
            userId: userId,
            topic: topic,
            totalAttempts: Value(1),
            totalCorrect: Value(correctCount),
            totalQuestions: Value(totalQuestions),
            averageScore: Value(scorePercentage),
            skillLevel: Value(_calculateSkillLevel(scorePercentage, 0.5)),
            lastAttemptAt: Value(DateTime.now()),
          ),
        );
  } else {
    final newTotalAttempts = existing.totalAttempts + 1;
    final newTotalCorrect = existing.totalCorrect + correctCount;
    final newTotalQuestions = existing.totalQuestions + totalQuestions;
    final newAverageScore =
        ((existing.averageScore * existing.totalAttempts) + scorePercentage) /
            newTotalAttempts;
    final newSkillLevel =
        _calculateSkillLevel(scorePercentage, existing.skillLevel);
    await (db.update(db.quizStatistics)..where((t) => t.id.equals(existing.id)))
        .write(QuizStatisticsCompanion(
      totalAttempts: Value(newTotalAttempts),
      totalCorrect: Value(newTotalCorrect),
      totalQuestions: Value(newTotalQuestions),
      averageScore: Value(newAverageScore),
      skillLevel: Value(newSkillLevel),
      lastAttemptAt: Value(DateTime.now()),
    ));
  }
}
double _calculateSkillLevel(double currentScore, double previousSkill) {
  final normalizedScore = currentScore / 100;
  return (previousSkill * 0.7) + (normalizedScore * 0.3);
}
Future<void> _updateLeaderboard(
  AppDatabase db,
  int userId,
  int score,
) async {
  final classIdsToUpdate = [null, 1];
  for (final cId in classIdsToUpdate) {
    final existing = await (db.select(db.leaderboards)
          ..where((t) =>
              t.userId.equals(userId) &
              t.period.equals('all_time') &
              (cId == null ? t.classId.isNull() : t.classId.equals(cId))))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.leaderboards).insert(
            LeaderboardsCompanion.insert(
              userId: userId,
              classId: Value(cId),
              period: 'all_time',
              totalScore: Value(score.toDouble()),
              quizzesCompleted: Value(1),
              updatedAt: DateTime.now(),
            ),
          );
    } else {
      await (db.update(db.leaderboards)..where((t) => t.id.equals(existing.id)))
          .write(LeaderboardsCompanion(
        totalScore: Value(existing.totalScore + score),
        quizzesCompleted: Value(existing.quizzesCompleted + 1),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }
}