import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final int userId;
  const LoadTasks(this.userId);
  @override
  List<Object> get props => [userId];
}

class AddTask extends TaskEvent {
  final TaskEntity task;
  const AddTask(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  const UpdateTask(this.task);
  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int taskId;
  final int userId;
  const DeleteTask(this.taskId, this.userId);
  @override
  List<Object> get props => [taskId, userId];
}
