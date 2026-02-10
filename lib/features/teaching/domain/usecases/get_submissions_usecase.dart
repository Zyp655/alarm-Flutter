import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class GetSubmissionsUseCase {
  final TeacherRepository repository;

  GetSubmissionsUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    int assignmentId,
  ) async {
    return await repository.getSubmissions(assignmentId);
  }
}
