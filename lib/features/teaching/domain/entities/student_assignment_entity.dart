import 'package:equatable/equatable.dart';

class StudentAssignmentEntity extends Equatable {
  final int id;
  final int studentAssignmentId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int rewardPoints;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool rewardClaimed;
  final String? className;
  final int classId;

  const StudentAssignmentEntity({
    required this.id,
    required this.studentAssignmentId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.rewardPoints,
    required this.createdAt,
    required this.isCompleted,
    this.completedAt,
    required this.rewardClaimed,
    this.className,
    required this.classId,
  });

  @override
  List<Object?> get props => [
    id,
    studentAssignmentId,
    title,
    description,
    dueDate,
    rewardPoints,
    createdAt,
    isCompleted,
    completedAt,
    rewardClaimed,
    className,
    classId,
  ];
}
