import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_statistics_entity.dart';
import '../../domain/entities/quiz_entity.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizGenerated extends QuizState {
  final QuizEntity quiz;

  const QuizGenerated(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizInProgress extends QuizState {
  final QuizEntity quiz;
  final int currentQuestionIndex;
  final List<dynamic> userAnswers;

  const QuizInProgress({
    required this.quiz,
    required this.currentQuestionIndex,
    required this.userAnswers,
  });

  @override
  List<Object?> get props => [quiz, currentQuestionIndex, userAnswers];
}

class QuizCompleted extends QuizState {
  final QuizResultEntity result;

  const QuizCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

class QuizSubmittedToServer extends QuizState {
  final int attemptId;
  final int correctCount;
  final int totalQuestions;
  final double scorePercentage;
  final bool passed;

  const QuizSubmittedToServer({
    required this.attemptId,
    required this.correctCount,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.passed,
  });

  @override
  List<Object?> get props => [
    attemptId,
    correctCount,
    totalQuestions,
    scorePercentage,
    passed,
  ];
}

class QuizSaved extends QuizState {
  final int quizId;

  const QuizSaved(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class MyQuizzesLoaded extends QuizState {
  final List<QuizEntity> quizzes;

  const MyQuizzesLoaded(this.quizzes);

  @override
  List<Object?> get props => [quizzes];
}

class StatisticsLoaded extends QuizState {
  final QuizStatisticsResponseEntity stats;

  const StatisticsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
