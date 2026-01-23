import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

class UpdateAssignmentUseCase {
  final TeacherRepository repository;

  UpdateAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call(
    AssignmentEntity assignment,
    int teacherId,
  ) async {
    return await repository.updateAssignment(assignment, teacherId);
  }
}
