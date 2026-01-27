import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/task_repository.dart';
import '../entities/task_entity.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    return await repository.createTask(task);
  }
}
