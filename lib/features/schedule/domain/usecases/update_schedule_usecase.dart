import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../enitities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class UpdateScheduleUseCase {
  final ScheduleRepository repository;
  UpdateScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(ScheduleEntity schedule) async {
    return await repository.updateSchedule(schedule);
  }
}