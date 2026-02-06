import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enrollment_entity.dart';
import '../repositories/course_repository.dart';

class EnrollCourseUseCase {
  final CourseRepository repository;

  EnrollCourseUseCase(this.repository);

  Future<Either<Failure, EnrollmentEntity>> call({
    required int userId,
    required int courseId,
  }) async {
    return await repository.enrollCourse(userId: userId, courseId: courseId);
  }
}
