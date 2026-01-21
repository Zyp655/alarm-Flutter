import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/schedule_repository.dart';

class JoinClassUseCase {
  final ScheduleRepository repository;

  JoinClassUseCase(this.repository);

  Future<Either<Failure, void>> call(String code) async {
    return await repository.joinClass(code);
  }
}