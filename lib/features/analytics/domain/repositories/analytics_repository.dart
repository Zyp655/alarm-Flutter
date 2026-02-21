import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/heatmap_entry.dart';
import '../entities/velocity_data.dart';
import '../entities/benchmark_data.dart';
import '../entities/analytics_summary.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, List<HeatmapEntry>>> getHeatmap({
    required int userId,
    int months = 6,
  });

  Future<Either<Failure, VelocityData>> getVelocity({
    required int userId,
    required int courseId,
  });

  Future<Either<Failure, BenchmarkData>> getBenchmark({
    required int userId,
    required int courseId,
  });

  Future<Either<Failure, AnalyticsSummary>> getSummary({required int userId});

  Future<Either<Failure, void>> trackActivity({
    required int userId,
    required String activityType,
    int? courseId,
    int? lessonId,
    int durationMinutes = 0,
    String? metadata,
  });
}
