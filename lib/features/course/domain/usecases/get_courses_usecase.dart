import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call({
    String? search,
    String? level,
    int? instructorId,
    int? majorId,
    bool showUnpublished = false,
  }) async {
    return await repository.getCourses(
      search: search,
      level: level,
      instructorId: instructorId,
      majorId: majorId,
      showUnpublished: showUnpublished,
    );
  }
}
