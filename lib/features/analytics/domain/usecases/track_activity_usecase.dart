import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/analytics_repository.dart';

class TrackActivityUseCase {
  final AnalyticsRepository repository;

  TrackActivityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int userId,
    required String activityType,
    int? courseId,
    int? lessonId,
    int durationMinutes = 0,
    String? metadata,
  }) {
    return repository.trackActivity(
      userId: userId,
      activityType: activityType,
      courseId: courseId,
      lessonId: lessonId,
      durationMinutes: durationMinutes,
      metadata: metadata,
    );
  }
}
