import '../../domain/entities/submission_entity.dart';

class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    required super.id,
    required super.studentId,
    super.studentName,
    super.textContent,
    super.linkUrl,
    required super.submittedAt,
    required super.status,
    super.grade,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      studentName: json['studentName'] as String?,
      textContent: json['textContent'] as String?,
      linkUrl: json['linkUrl'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: json['status'] as String,
      grade: (json['grade'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'textContent': textContent,
      'linkUrl': linkUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'grade': grade,
    };
  }
}
