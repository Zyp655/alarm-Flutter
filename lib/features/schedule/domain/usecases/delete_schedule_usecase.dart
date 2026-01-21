import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/schedule_repository.dart';

class DeleteScheduleUseCase {
  final ScheduleRepository repository;
  DeleteScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteSchedule(id);
  }
}