import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/velocity_data.dart';
import '../repositories/analytics_repository.dart';

class GetVelocityUseCase {
  final AnalyticsRepository repository;

  GetVelocityUseCase(this.repository);

  Future<Either<Failure, VelocityData>> call({
    required int userId,
    required int courseId,
  }) {
    return repository.getVelocity(userId: userId, courseId: courseId);
  }
}
