import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/course_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteLessonUseCase {
  final CourseRepository repository;

  DeleteLessonUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteLessonParams params) async {
    return await repository.deleteLesson(
      courseId: params.courseId,
      moduleId: params.moduleId,
      lessonId: params.lessonId,
    );
  }
}

class DeleteLessonParams extends Equatable {
  final int courseId;
  final int moduleId;
  final int lessonId;

  const DeleteLessonParams({
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  List<Object?> get props => [courseId, moduleId, lessonId];
}
