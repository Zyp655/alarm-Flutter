import '../../domain/entities/submission_entity.dart';

class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    super.id,
    required super.assignmentId,
    required super.studentId,
    super.fileUrl,
    super.fileName,
    super.fileSize,
    super.linkUrl,
    super.textContent,
    required super.submittedAt,
    super.isLate,
    super.status,
    super.grade,
    super.maxGrade,
    super.feedback,
    super.gradedAt,
    super.gradedBy,
    super.version,
    super.previousVersionId,
    super.studentName,
    super.studentEmail,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as int?,
      assignmentId: json['assignmentId'] as int,
      studentId: json['studentId'] as int,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      linkUrl: json['linkUrl'] as String?,
      textContent: json['textContent'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      isLate: json['isLate'] as bool? ?? false,
      status: json['status'] as String? ?? 'submitted',
      grade: (json['grade'] as num?)?.toDouble(),
      maxGrade: (json['maxGrade'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      gradedAt: json['gradedAt'] != null
          ? DateTime.parse(json['gradedAt'] as String)
          : null,
      gradedBy: json['gradedBy'] as int?,
      version: json['version'] as int? ?? 1,
      previousVersionId: json['previousVersionId'] as int?,
      studentName: json['studentName'] as String?,
      studentEmail: json['studentEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'linkUrl': linkUrl,
      'textContent': textContent,
      'submittedAt': submittedAt.toIso8601String(),
      'isLate': isLate,
      'status': status,
      'grade': grade,
      'maxGrade': maxGrade,
      'feedback': feedback,
      'gradedAt': gradedAt?.toIso8601String(),
      'gradedBy': gradedBy,
      'version': version,
      'previousVersionId': previousVersionId,
      'studentName': studentName,
      'studentEmail': studentEmail,
    };
  }

  factory SubmissionModel.fromEntity(SubmissionEntity entity) {
    return SubmissionModel(
      id: entity.id,
      assignmentId: entity.assignmentId,
      studentId: entity.studentId,
      fileUrl: entity.fileUrl,
      fileName: entity.fileName,
      fileSize: entity.fileSize,
      linkUrl: entity.linkUrl,
      textContent: entity.textContent,
      submittedAt: entity.submittedAt,
      isLate: entity.isLate,
      status: entity.status,
      grade: entity.grade,
      maxGrade: entity.maxGrade,
      feedback: entity.feedback,
      gradedAt: entity.gradedAt,
      gradedBy: entity.gradedBy,
      version: entity.version,
      previousVersionId: entity.previousVersionId,
      studentName: entity.studentName,
      studentEmail: entity.studentEmail,
    );
  }
}
