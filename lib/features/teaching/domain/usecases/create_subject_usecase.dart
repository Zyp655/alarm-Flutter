import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class CreateSubjectUseCase {
  final TeacherRepository repository;

  CreateSubjectUseCase(this.repository);

  Future<Either<Failure, void>> call(
    int teacherId,
    String name,
    int credits,
    String? code,
  ) async {
    return await repository.createSubject(teacherId, name, credits, code);
  }
}
