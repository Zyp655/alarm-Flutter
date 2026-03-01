import 'package:get_it/get_it.dart';
import '../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../features/analytics/domain/repositories/analytics_repository.dart';
import '../features/analytics/domain/usecases/get_summary_usecase.dart';
import '../features/analytics/domain/usecases/get_heatmap_usecase.dart';
import '../features/analytics/domain/usecases/get_velocity_usecase.dart';
import '../features/analytics/domain/usecases/get_benchmark_usecase.dart';
import '../features/analytics/domain/usecases/track_activity_usecase.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';

void initAnalyticsModule(GetIt sl) {
  sl.registerLazySingleton(() => AnalyticsRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetHeatmapUseCase(sl()));
  sl.registerLazySingleton(() => GetVelocityUseCase(sl()));
  sl.registerLazySingleton(() => GetBenchmarkUseCase(sl()));
  sl.registerLazySingleton(() => TrackActivityUseCase(sl()));
  sl.registerFactory(
    () => AnalyticsBloc(
      getSummary: sl(),
      getHeatmap: sl(),
      getVelocity: sl(),
      getBenchmark: sl(),
      trackActivity: sl(),
    ),
  );
}
