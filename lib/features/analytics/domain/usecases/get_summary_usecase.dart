import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analytics_summary.dart';
import '../repositories/analytics_repository.dart';

class GetSummaryUseCase {
  final AnalyticsRepository repository;

  GetSummaryUseCase(this.repository);

  Future<Either<Failure, AnalyticsSummary>> call({required int userId}) {
    return repository.getSummary(userId: userId);
  }
}
