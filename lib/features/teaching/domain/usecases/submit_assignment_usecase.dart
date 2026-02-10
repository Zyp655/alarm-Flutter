import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class SubmitAssignmentUseCase {
  final StudentRepository repository;

  SubmitAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int assignmentId,
    required int studentId,
    File? file,
    String? link,
    String? text,
  }) async {
    return await repository.submitAssignment(
      assignmentId: assignmentId,
      studentId: studentId,
      file: file,
      link: link,
      text: text,
    );
  }
}
