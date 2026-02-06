import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';

class ModuleEntity extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final DateTime createdAt;
  final List<LessonEntity>? lessons;

  const ModuleEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.createdAt,
    this.lessons,
  });

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    description,
    orderIndex,
    createdAt,
  ];
}
