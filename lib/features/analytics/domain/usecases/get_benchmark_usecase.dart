import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/benchmark_data.dart';
import '../repositories/analytics_repository.dart';

class GetBenchmarkUseCase {
  final AnalyticsRepository repository;

  GetBenchmarkUseCase(this.repository);

  Future<Either<Failure, BenchmarkData>> call({
    required int userId,
    required int courseId,
  }) {
    return repository.getBenchmark(userId: userId, courseId: courseId);
  }
}
