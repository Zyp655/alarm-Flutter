import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/heatmap_entry.dart';
import '../repositories/analytics_repository.dart';

class GetHeatmapUseCase {
  final AnalyticsRepository repository;

  GetHeatmapUseCase(this.repository);

  Future<Either<Failure, List<HeatmapEntry>>> call({
    required int userId,
    int months = 6,
  }) {
    return repository.getHeatmap(userId: userId, months: months);
  }
}
