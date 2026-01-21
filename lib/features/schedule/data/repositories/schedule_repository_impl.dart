import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/enitities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getSchedules() async {
    try {
      final result = await remoteDataSource.getSchedules();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi lấy lịch học'));
    }
  }

  @override
  Future<Either<Failure, void>> addSchedule(
      List<ScheduleEntity> schedules,
      ) async {
    try {
      final models = schedules.map((e) => ScheduleModel.fromEntity(e)).toList();
      await remoteDataSource.addSchedule(models);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi thêm lịch học'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(int id) async {
    try {
      await remoteDataSource.deleteSchedule(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi xóa lịch học'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSchedule(ScheduleEntity schedule) async {
    try {
      final model = ScheduleModel.fromEntity(schedule);
      await remoteDataSource.updateSchedule(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi cập nhật lịch học'));
    }
  }
  @override
  Future<Either<Failure, void>> joinClass(String code) async {
    try {
      await remoteDataSource.joinClass(code);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}