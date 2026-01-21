import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../enitities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class GetSchedulesUseCase {
  final ScheduleRepository repository;

  GetSchedulesUseCase(this.repository);

  Future<Either<Failure, List<ScheduleEntity>>> call() {
    return repository.getSchedules();
  }
}