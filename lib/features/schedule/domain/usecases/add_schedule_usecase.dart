import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../enitities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class AddScheduleUseCase {
  final ScheduleRepository repository;

  AddScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(List<ScheduleEntity> schedules) async {
    return await repository.addSchedule(schedules);
  }
}