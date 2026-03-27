import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAssignmentEvent extends StudentEvent {
  final int assignmentId;
  final int studentId;
  final Uint8List? fileBytes;
  final String? fileName;
  final String? link;
  final String? text;

  const SubmitAssignmentEvent({
    required this.assignmentId,
    required this.studentId,
    this.fileBytes,
    this.fileName,
    this.link,
    this.text,
  });

  @override
  List<Object?> get props => [assignmentId, studentId, fileBytes, fileName, link, text];
}

class GetStudentAssignmentsEvent extends StudentEvent {
  final int studentId;

  const GetStudentAssignmentsEvent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}
