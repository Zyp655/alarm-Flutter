import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subject_entity.dart';
import '../repositories/teacher_repository.dart';

class GetSubjectsUseCase {
  final TeacherRepository repository;

  GetSubjectsUseCase(this.repository);

  Future<Either<Failure, List<SubjectEntity>>> call(int teacherId) async {
    return await repository.getSubjects(teacherId);
  }
}