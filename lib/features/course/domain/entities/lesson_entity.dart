import 'package:equatable/equatable.dart';

enum LessonType { video, text, quiz, assignment }

class LessonEntity extends Equatable {
  final int id;
  final int moduleId;
  final String title;
  final LessonType type;
  final String? contentUrl;
  final String? textContent;
  final int? quizId;
  final int? assignmentId;
  final int durationMinutes;
  final bool isFreePreview;
  final int orderIndex;
  final bool isCompleted;
  final DateTime createdAt;

  const LessonEntity({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.type,
    this.contentUrl,
    this.textContent,
    this.quizId,
    this.assignmentId,
    required this.durationMinutes,
    required this.isFreePreview,
    required this.orderIndex,
    this.isCompleted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    moduleId,
    title,
    type,
    contentUrl,
    textContent,
    quizId,
    assignmentId,
    durationMinutes,
    isFreePreview,
    orderIndex,
    isCompleted,
    createdAt,
  ];
}
