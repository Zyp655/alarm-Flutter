import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/course_repository.dart';

class UpdateLessonProgressUseCase {
  final CourseRepository repository;

  UpdateLessonProgressUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int userId,
    required int lessonId,
    int lastWatchedPosition = 0,
    bool isCompleted = false,
  }) async {
    return await repository.updateLessonProgress(
      userId: userId,
      lessonId: lessonId,
      lastWatchedPosition: lastWatchedPosition,
      isCompleted: isCompleted,
    );
  }
}
