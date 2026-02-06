import 'package:equatable/equatable.dart';

abstract class LearningPlayerEvent extends Equatable {
  const LearningPlayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadLessonEvent extends LearningPlayerEvent {
  final int lessonId;
  final int userId;

  const LoadLessonEvent({required this.lessonId, required this.userId});

  @override
  List<Object?> get props => [lessonId, userId];
}

class UpdateProgressEvent extends LearningPlayerEvent {
  final int userId;
  final int lessonId;
  final int currentPosition; 
  final bool isCompleted;

  const UpdateProgressEvent({
    required this.userId,
    required this.lessonId,
    required this.currentPosition,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [userId, lessonId, currentPosition, isCompleted];
}

class MarkLessonCompleteEvent extends LearningPlayerEvent {
  final int userId;
  final int lessonId;

  const MarkLessonCompleteEvent({required this.userId, required this.lessonId});

  @override
  List<Object?> get props => [userId, lessonId];
}
