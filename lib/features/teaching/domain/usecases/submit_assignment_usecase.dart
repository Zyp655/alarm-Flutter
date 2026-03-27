import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/student_repository.dart';

class SubmitAssignmentUseCase {
  final StudentRepository repository;

  SubmitAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int assignmentId,
    required int studentId,
    Uint8List? fileBytes,
    String? fileName,
    String? link,
    String? text,
  }) async {
    return await repository.submitAssignment(
      assignmentId: assignmentId,
      studentId: studentId,
      fileBytes: fileBytes,
      fileName: fileName,
      link: link,
      text: text,
    );
  }
}
