import 'package:equatable/equatable.dart';

class AssignmentEntity extends Equatable {
  final int? id;
  final int classId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int rewardPoints;
  final DateTime? createdAt;
  final int? totalStudents;
  final int? completedStudents;

  const AssignmentEntity({
    this.id,
    required this.classId,
    required this.title,
    this.description,
    required this.dueDate,
    this.rewardPoints = 0,
    this.createdAt,
    this.totalStudents,
    this.completedStudents,
  });

  @override
  List<Object?> get props => [
    id,
    classId,
    title,
    description,
    dueDate,
    rewardPoints,
    createdAt,
    totalStudents,
    completedStudents,
  ];
}
