import 'package:get_it/get_it.dart';
import '../features/task/data/datasources/task_remote_data_source.dart';
import '../features/task/data/repositories/task_repository_impl.dart';
import '../features/task/domain/repositories/task_repository.dart';
import '../features/task/domain/usecases/get_tasks_usecase.dart';
import '../features/task/domain/usecases/create_task_usecase.dart';
import '../features/task/domain/usecases/update_task_usecase.dart';
import '../features/task/domain/usecases/delete_task_usecase.dart';
import '../features/task/presentation/bloc/task_bloc.dart';

void initTaskModule(GetIt sl) {
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      createTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
    ),
  );
}
