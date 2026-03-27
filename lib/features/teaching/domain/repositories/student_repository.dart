import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student_assignment_entity.dart';

abstract class StudentRepository {
  Future<Either<Failure, void>> submitAssignment({
    required int assignmentId,
    required int studentId,
    Uint8List? fileBytes,
    String? fileName,
    String? link,
    String? text,
  });

  Future<Either<Failure, List<StudentAssignmentEntity>>> getStudentAssignments(
    int studentId,
  );
}
