import 'package:equatable/equatable.dart';

class SubmissionEntity extends Equatable {
  final int? id;
  final int assignmentId;
  final int studentId;

  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? linkUrl;
  final String? textContent;

  final DateTime submittedAt;
  final bool isLate;
  final String status;

  final double? grade;
  final double? maxGrade;
  final String? feedback;
  final DateTime? gradedAt;
  final int? gradedBy;

  final int version;
  final int? previousVersionId;

  final String? studentName;
  final String? studentEmail;

  const SubmissionEntity({
    this.id,
    required this.assignmentId,
    required this.studentId,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.linkUrl,
    this.textContent,
    required this.submittedAt,
    this.isLate = false,
    this.status = 'submitted',
    this.grade,
    this.maxGrade,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
    this.version = 1,
    this.previousVersionId,
    this.studentName,
    this.studentEmail,
  });

  @override
  List<Object?> get props => [
    id,
    assignmentId,
    studentId,
    fileUrl,
    fileName,
    fileSize,
    linkUrl,
    textContent,
    submittedAt,
    isLate,
    status,
    grade,
    maxGrade,
    feedback,
    gradedAt,
    gradedBy,
    version,
    previousVersionId,
    studentName,
    studentEmail,
  ];
}
