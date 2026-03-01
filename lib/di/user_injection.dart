import 'package:get_it/get_it.dart';
import '../features/user/data/datasources/user_remote_data_source.dart';
import '../features/user/data/repositories/user_repository_impl.dart';
import '../features/user/domain/repositories/user_repository.dart';
import '../features/user/domain/usecases/get_user_profile_usecase.dart';
import '../features/user/domain/usecases/update_user_profile_usecase.dart';
import '../features/user/presentation/bloc/user_bloc.dart';
import '../features/user/data/datasources/teacher_application_remote_data_source.dart';
import '../features/user/presentation/bloc/teacher_app_bloc.dart';

void initUserModule(GetIt sl) {
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerFactory(
    () => UserBloc(getUserProfile: sl(), updateUserProfile: sl()),
  );

  sl.registerLazySingleton<TeacherApplicationRemoteDataSource>(
    () => TeacherApplicationRemoteDataSource(apiClient: sl()),
  );
  sl.registerFactory(() => TeacherAppBloc(dataSource: sl()));
}
