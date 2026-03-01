import 'package:get_it/get_it.dart';
import '../features/roadmap/data/repositories/roadmap_repository_impl.dart';
import '../features/roadmap/domain/repositories/roadmap_repository.dart';
import '../features/roadmap/domain/usecases/roadmap_usecases.dart';
import '../features/roadmap/presentation/bloc/roadmap_bloc.dart';

void initRoadmapModule(GetIt sl) {
  sl.registerLazySingleton<RoadmapRepository>(
    () => RoadmapRepositoryImpl(apiClient: sl()),
  );
  sl.registerLazySingleton(() => GetPersonalRoadmapUseCase(sl()));
  sl.registerLazySingleton(() => ResetRoadmapUseCase(sl()));
  sl.registerLazySingleton(() => AddRoadmapItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRoadmapItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveRoadmapItemUseCase(sl()));
  sl.registerLazySingleton(() => GetRoadmapSuggestionsUseCase(sl()));
  sl.registerFactory(
    () => RoadmapBloc(
      getPersonalRoadmap: sl(),
      resetRoadmap: sl(),
      addRoadmapItem: sl(),
      updateRoadmapItem: sl(),
      removeRoadmapItem: sl(),
      getSuggestions: sl(),
    ),
  );
}
