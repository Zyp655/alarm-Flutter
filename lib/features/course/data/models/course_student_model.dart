import '../../domain/entities/course_student_entity.dart';

class CourseStudentModel extends CourseStudentEntity {
  const CourseStudentModel({
    required super.userId,
    required super.fullName,
    required super.email,
    super.avatarUrl,
    required super.progressPercent,
    required super.enrolledAt,
    super.completedAt,
    super.lastAccessedAt,
  });

  factory CourseStudentModel.fromJson(Map<String, dynamic> json) {
    return CourseStudentModel(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      progressPercent: (json['progressPercent'] as num).toDouble(),
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'progressPercent': progressPercent,
      'enrolledAt': enrolledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    };
  }
}
