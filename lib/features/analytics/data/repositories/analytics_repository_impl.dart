import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/heatmap_entry.dart';
import '../../domain/entities/velocity_data.dart';
import '../../domain/entities/benchmark_data.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HeatmapEntry>>> getHeatmap({
    required int userId,
    int months = 6,
  }) async {
    try {
      final json = await remoteDataSource.getHeatmap(userId, months);
      return Right(remoteDataSource.parseHeatmap(json));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to load heatmap: $e'));
    }
  }

  @override
  Future<Either<Failure, VelocityData>> getVelocity({
    required int userId,
    required int courseId,
  }) async {
    try {
      final json = await remoteDataSource.getVelocity(userId, courseId);
      return Right(remoteDataSource.parseVelocity(json));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to load velocity: $e'));
    }
  }

  @override
  Future<Either<Failure, BenchmarkData>> getBenchmark({
    required int userId,
    required int courseId,
  }) async {
    try {
      final json = await remoteDataSource.getBenchmark(userId, courseId);
      return Right(remoteDataSource.parseBenchmark(json));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to load benchmark: $e'));
    }
  }

  @override
  Future<Either<Failure, AnalyticsSummary>> getSummary({
    required int userId,
  }) async {
    try {
      final json = await remoteDataSource.getSummary(userId);
      return Right(remoteDataSource.parseSummary(json));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to load summary: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> trackActivity({
    required int userId,
    required String activityType,
    int? courseId,
    int? lessonId,
    int durationMinutes = 0,
    String? metadata,
  }) async {
    try {
      await remoteDataSource.trackActivity(
        userId: userId,
        activityType: activityType,
        courseId: courseId,
        lessonId: lessonId,
        durationMinutes: durationMinutes,
        metadata: metadata,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to track activity: $e'));
    }
  }
}
