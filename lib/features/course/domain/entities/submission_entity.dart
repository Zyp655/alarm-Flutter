import 'package:equatable/equatable.dart';

class SubmissionEntity extends Equatable {
  final int id;
  final int studentId;
  final String? studentName;
  final String? textContent;
  final String? linkUrl;
  final DateTime submittedAt;
  final String status;
  final double? grade;

  const SubmissionEntity({
    required this.id,
    required this.studentId,
    this.studentName,
    this.textContent,
    this.linkUrl,
    required this.submittedAt,
    required this.status,
    this.grade,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    textContent,
    linkUrl,
    submittedAt,
    status,
    grade,
  ];
}
