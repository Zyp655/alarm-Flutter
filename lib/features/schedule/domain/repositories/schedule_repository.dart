import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../enitities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<ScheduleEntity>>> getSchedules();

  Future<Either<Failure, void>> joinClass(String code);

  Future<Either<Failure, void>> addSchedule(List<ScheduleEntity> schedules);

  Future<Either<Failure, void>> deleteSchedule(int id);

  Future<Either<Failure, void>> updateSchedule(ScheduleEntity schedule);
}
