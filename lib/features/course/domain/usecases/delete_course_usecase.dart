import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/course_repository.dart';

class DeleteCourseUseCase {
  final CourseRepository repository;

  DeleteCourseUseCase(this.repository);

  Future<Either<Failure, void>> call(int courseId) async {
    return await repository.deleteCourse(courseId);
  }
}
