import 'package:equatable/equatable.dart';
import 'course_entity.dart';

class EnrollmentEntity extends Equatable {
  final int id;
  final int userId;
  final int courseId;
  final double progressPercent;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final CourseEntity? course; 

  const EnrollmentEntity({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.progressPercent,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
    this.course,
  });

  bool get isCompleted => progressPercent >= 100.0;
  bool get isInProgress => progressPercent > 0 && progressPercent < 100.0;

  @override
  List<Object?> get props => [
    id,
    userId,
    courseId,
    progressPercent,
    enrolledAt,
    completedAt,
    lastAccessedAt,
    course,
  ];
}
