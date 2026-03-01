import 'package:get_it/get_it.dart';
import '../features/profile/data/datasources/achievement_remote_datasource.dart';
import '../features/profile/data/repositories/achievement_repository_impl.dart';
import '../features/profile/domain/repositories/achievement_repository.dart';
import '../features/profile/domain/usecases/get_achievements_usecase.dart';
import '../features/profile/presentation/bloc/achievement_bloc.dart';

void initProfileModule(GetIt sl) {
  sl.registerLazySingleton<AchievementRemoteDataSource>(
    () => AchievementRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetAchievementsUseCase(sl()));
  sl.registerFactory(() => AchievementBloc(getAchievements: sl()));
}
