import 'package:equatable/equatable.dart';

class LessonProgressEntity extends Equatable {
  final int id;
  final int userId;
  final int lessonId;
  final bool isCompleted;
  final int lastWatchedPosition;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const LessonProgressEntity({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.isCompleted,
    required this.lastWatchedPosition,
    this.completedAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    lessonId,
    isCompleted,
    lastWatchedPosition,
    completedAt,
    updatedAt,
  ];
}
