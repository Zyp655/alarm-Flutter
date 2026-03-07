import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository repository;

  CreateCourseUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call({
    required String name,
    required String code,
    required int credits,
    String? description,
    String courseType = 'required',
  }) async {
    return await repository.createCourse(
      name: name,
      code: code,
      credits: credits,
      description: description,
      courseType: courseType,
    );
  }
}
