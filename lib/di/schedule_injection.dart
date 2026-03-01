import 'package:get_it/get_it.dart';
import '../features/schedule/data/datasources/schedule_remote_data_source.dart';
import '../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../features/schedule/domain/repositories/schedule_repository.dart';
import '../features/schedule/domain/usecases/add_schedule_usecase.dart';
import '../features/schedule/domain/usecases/get_schedules_usecase.dart';
import '../features/schedule/domain/usecases/delete_schedule_usecase.dart';
import '../features/schedule/domain/usecases/join_class_usecase.dart';
import '../features/schedule/domain/usecases/update_schedule_usecase.dart';
import '../features/schedule/presentation/bloc/schedule_bloc.dart';

void initScheduleModule(GetIt sl) {
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetSchedulesUseCase(sl()));
  sl.registerLazySingleton(() => AddScheduleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteScheduleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateScheduleUseCase(sl()));
  sl.registerLazySingleton(() => JoinClassUseCase(sl()));
  sl.registerFactory(
    () => ScheduleBloc(
      getSchedulesUseCase: sl(),
      addScheduleUseCase: sl(),
      deleteScheduleUseCase: sl(),
      updateScheduleUseCase: sl(),
      joinClassUseCase: sl(),
    ),
  );
}
