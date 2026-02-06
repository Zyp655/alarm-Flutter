import 'package:equatable/equatable.dart';

class CourseStudentEntity extends Equatable {
  final int userId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final double progressPercent;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  const CourseStudentEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.progressPercent,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    avatarUrl,
    progressPercent,
    enrolledAt,
    completedAt,
    lastAccessedAt,
  ];
}
