import '../../domain/entities/enrollment_entity.dart';
import 'course_model.dart';

class EnrollmentModel extends EnrollmentEntity {
  const EnrollmentModel({
    required super.id,
    required super.userId,
    required super.courseId,
    required super.progressPercent,
    required super.enrolledAt,
    super.completedAt,
    super.lastAccessedAt,
    super.course,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      courseId: json['courseId'] as int,
      progressPercent: (json['progressPercent'] as num).toDouble(),
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
      course: json['course'] != null
          ? CourseModel.fromJson(json['course'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'progressPercent': progressPercent,
      'enrolledAt': enrolledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      if (course != null) 'course': (course as CourseModel).toJson(),
    };
  }
}
