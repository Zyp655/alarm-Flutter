import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository repository;

  CreateCourseUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call({
    required String title,
    required int instructorId,
    String? description,
    String? level,
  }) async {
    return await repository.createCourse(
      title: title,
      instructorId: instructorId,
      description: description,
      level: level ?? 'beginner',
    );
  }
}
