import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/module_entity.dart';
import '../repositories/course_repository.dart';

class GetCourseCurriculumUseCase {
  final CourseRepository repository;

  GetCourseCurriculumUseCase(this.repository);

  Future<Either<Failure, List<ModuleEntity>>> call(int courseId) async {
    return await repository.getCourseCurriculum(courseId);
  }
}
