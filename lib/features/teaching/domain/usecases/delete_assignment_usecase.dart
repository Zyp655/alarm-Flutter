import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/teacher_repository.dart';

class DeleteAssignmentUseCase {
  final TeacherRepository repository;

  DeleteAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call(int assignmentId, int teacherId) async {
    return await repository.deleteAssignment(assignmentId, teacherId);
  }
}
