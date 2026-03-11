import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class GenerateQuizEvent extends QuizEvent {
  final String topic;
  final int numQuestions;
  final String difficulty;
  final String? subjectContext;
  final List<String>? questionTypes;
  final String? videoUrl;

  const GenerateQuizEvent({
    required this.topic,
    required this.numQuestions,
    required this.difficulty,
    this.subjectContext,
    this.questionTypes,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [
    topic,
    numQuestions,
    difficulty,
    subjectContext,
    questionTypes,
    videoUrl,
  ];
}

class GenerateQuizFromImageEvent extends QuizEvent {
  final Uint8List imageBytes;
  final int numQuestions;
  final String difficulty;

  const GenerateQuizFromImageEvent({
    required this.imageBytes,
    required this.numQuestions,
    required this.difficulty,
  });

  @override
  List<Object?> get props => [imageBytes, numQuestions, difficulty];
}

class GenerateAdaptiveQuizEvent extends QuizEvent {
  final int userId;
  final String topic;
  final int numQuestions;

  const GenerateAdaptiveQuizEvent({
    required this.userId,
    required this.topic,
    required this.numQuestions,
  });

  @override
  List<Object?> get props => [userId, topic, numQuestions];
}

class AnswerQuestionEvent extends QuizEvent {
  final int questionIndex;
  final dynamic answer;

  const AnswerQuestionEvent({
    required this.questionIndex,
    required this.answer,
  });

  @override
  List<Object?> get props => [questionIndex, answer];
}

class SubmitQuizEvent extends QuizEvent {
  const SubmitQuizEvent();
}

class SubmitQuizToServerEvent extends QuizEvent {
  final int userId;
  final int quizId;
  final int timeSpentSeconds;

  const SubmitQuizToServerEvent({
    required this.userId,
    required this.quizId,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [userId, quizId, timeSpentSeconds];
}

class SaveQuizEvent extends QuizEvent {
  final int userId;
  final bool isPublic;

  const SaveQuizEvent({required this.userId, this.isPublic = false});

  @override
  List<Object?> get props => [userId, isPublic];
}

class LoadQuizEvent extends QuizEvent {
  final int quizId;

  const LoadQuizEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

class LoadMyQuizzesEvent extends QuizEvent {
  final int userId;

  const LoadMyQuizzesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadStatisticsEvent extends QuizEvent {
  final int userId;
  final String? topic;

  const LoadStatisticsEvent({required this.userId, this.topic});

  @override
  List<Object?> get props => [userId, topic];
}

class ResetQuizEvent extends QuizEvent {
  const ResetQuizEvent();
}
