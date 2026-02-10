import 'package:dartz/dartz.dart';
import '../entities/submission_entity.dart';
import '../../../../core/error/failures.dart';

import '../repositories/teacher_repository.dart';

class GetAllSubmissionsUseCase {
  final TeacherRepository repository;

  GetAllSubmissionsUseCase(this.repository);

  Future<Either<Failure, List<SubmissionEntity>>> call(int assignmentId) async {
    throw UnimplementedError();
  }
}
