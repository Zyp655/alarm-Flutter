import 'package:dartz/dartz.dart';
import '../entities/submission_entity.dart';
import '../../../../core/error/failures.dart';

import '../repositories/teacher_repository.dart';

class GetSubmissionUseCase {
  final TeacherRepository repository;

  GetSubmissionUseCase(this.repository);

  Future<Either<Failure, SubmissionEntity>> call({
    required int assignmentId,
    required int studentId,
  }) async {
    throw UnimplementedError();
  }
}
