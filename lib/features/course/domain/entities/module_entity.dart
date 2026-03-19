import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';

class ModuleEntity extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String? description;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime? unlockDate;
  final List<LessonEntity>? lessons;

  const ModuleEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.createdAt,
    this.unlockDate,
    this.lessons,
  });

  bool get isUnlocked {
    if (unlockDate == null) return true;
    return DateTime.now().isAfter(unlockDate!) ||
        DateTime.now().day == unlockDate!.day &&
            DateTime.now().month == unlockDate!.month &&
            DateTime.now().year == unlockDate!.year;
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    description,
    orderIndex,
    createdAt,
    unlockDate,
  ];
}
