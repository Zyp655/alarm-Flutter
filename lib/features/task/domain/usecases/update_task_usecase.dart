import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/task_repository.dart';
import '../entities/task_entity.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    return await repository.updateTask(task);
  }
}
