import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

class CreateAssignmentUseCase {
  final TeacherRepository repository;

  CreateAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call(
    AssignmentEntity assignment,
    int teacherId,
  ) async {
    return await repository.createAssignment(assignment, teacherId);
  }
}
