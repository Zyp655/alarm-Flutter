import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

class GetStudentsInClassUseCase {
  final TeacherRepository repository;

  GetStudentsInClassUseCase(this.repository);

  Future<Either<Failure, List<StudentEntity>>> call(int classId) async {
    return await repository.getStudentsInClass(classId);
  }
}
