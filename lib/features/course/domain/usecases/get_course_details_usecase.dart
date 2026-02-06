import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCourseDetailsUseCase {
  final CourseRepository repository;

  GetCourseDetailsUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call(
    int courseId, {
    int? userId,
  }) async {
    return await repository.getCourseDetails(courseId, userId: userId);
  }
}
