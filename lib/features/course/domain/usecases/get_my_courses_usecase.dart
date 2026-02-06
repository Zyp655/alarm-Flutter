import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enrollment_entity.dart';
import '../repositories/course_repository.dart';

class GetMyCoursesUseCase {
  final CourseRepository repository;

  GetMyCoursesUseCase(this.repository);

  Future<Either<Failure, List<EnrollmentEntity>>> call(int userId) async {
    return await repository.getMyEnrollments(userId);
  }
}
