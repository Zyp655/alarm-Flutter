import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAssignmentEvent extends StudentEvent {
  final int assignmentId;
  final int studentId;
  final File? file;
  final String? link;
  final String? text;

  const SubmitAssignmentEvent({
    required this.assignmentId,
    required this.studentId,
    this.file,
    this.link,
    this.text,
  });

  @override
  List<Object?> get props => [assignmentId, studentId, file, link, text];
}

class GetStudentAssignmentsEvent extends StudentEvent {
  final int studentId;

  const GetStudentAssignmentsEvent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}
