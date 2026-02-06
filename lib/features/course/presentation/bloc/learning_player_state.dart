import 'package:equatable/equatable.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/lesson_progress_entity.dart';

abstract class LearningPlayerState extends Equatable {
  const LearningPlayerState();

  @override
  List<Object?> get props => [];
}

class LearningPlayerInitial extends LearningPlayerState {}

class LearningPlayerLoading extends LearningPlayerState {}

class LearningPlayerLoaded extends LearningPlayerState {
  final LessonEntity lesson;
  final LessonProgressEntity? progress;

  const LearningPlayerLoaded({required this.lesson, this.progress});

  int get lastPosition => progress?.lastWatchedPosition ?? 0;
  bool get isCompleted => progress?.isCompleted ?? false;

  @override
  List<Object?> get props => [lesson, progress];

  LearningPlayerLoaded copyWith({
    LessonEntity? lesson,
    LessonProgressEntity? progress,
  }) {
    return LearningPlayerLoaded(
      lesson: lesson ?? this.lesson,
      progress: progress ?? this.progress,
    );
  }
}

class LearningPlayerError extends LearningPlayerState {
  final String message;

  const LearningPlayerError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProgressUpdated extends LearningPlayerState {}
