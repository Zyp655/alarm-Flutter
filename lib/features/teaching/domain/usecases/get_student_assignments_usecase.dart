import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student_assignment_entity.dart';
import '../../domain/repositories/student_repository.dart';

class GetStudentAssignmentsUseCase {
  final StudentRepository repository;

  GetStudentAssignmentsUseCase(this.repository);

  Future<Either<Failure, List<StudentAssignmentEntity>>> call(
    int studentId,
  ) async {
    return await repository.getStudentAssignments(studentId);
  }
}
