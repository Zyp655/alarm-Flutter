import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final int userId;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    isCompleted,
    userId,
  ];
}
