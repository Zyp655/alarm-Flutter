import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

class GetAssignmentsUseCase {
  final TeacherRepository repository;

  GetAssignmentsUseCase(this.repository);

  Future<Either<Failure, List<AssignmentEntity>>> call(int teacherId) async {
    return await repository.getAssignments(teacherId);
  }
}
