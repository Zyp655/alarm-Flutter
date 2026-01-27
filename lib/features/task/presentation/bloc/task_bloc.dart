import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasks;
  final CreateTaskUseCase createTask;
  final UpdateTaskUseCase updateTask;
  final DeleteTaskUseCase deleteTask;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTasks(event.userId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TaskLoaded(tasks)),
    );
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await createTask(event.task);
    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      emit(const TaskOperationSuccess("Thêm công việc thành công"));
      add(LoadTasks(event.task.userId));
    });
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final result = await updateTask(event.task);
    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      add(LoadTasks(event.task.userId));
    });
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final result = await deleteTask(event.taskId);
    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      emit(const TaskOperationSuccess("Xóa công việc thành công"));
      add(LoadTasks(event.userId));
    });
  }
}
