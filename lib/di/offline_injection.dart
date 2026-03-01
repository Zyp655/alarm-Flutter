import 'package:get_it/get_it.dart';
import '../features/offline/data/datasources/offline_local_datasource.dart';
import '../features/offline/data/repositories/offline_repository_impl.dart';
import '../features/offline/data/services/connectivity_service.dart';
import '../features/offline/data/services/download_manager.dart';
import '../features/offline/data/services/encryption_service.dart';
import '../features/offline/data/services/sync_service.dart';
import '../features/offline/domain/repositories/offline_repository.dart';
import '../features/offline/domain/usecases/offline_usecases.dart';
import '../features/offline/presentation/bloc/offline_bloc.dart';

void initOfflineModule(GetIt sl) {
  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerLazySingleton(() => EncryptionService());
  sl.registerLazySingleton(() => OfflineLocalDataSource());
  sl.registerLazySingleton(() => DownloadManager(encryptionService: sl()));
  sl.registerLazySingleton(
    () => SyncService(
      localDataSource: sl(),
      apiClient: sl(),
      connectivityService: sl(),
    ),
  );
  sl.registerLazySingleton<OfflineRepository>(
    () => OfflineRepositoryImpl(
      localDataSource: sl(),
      downloadManager: sl(),
      syncService: sl(),
      encryptionService: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetOfflineStatusUseCase(sl()));
  sl.registerLazySingleton(() => DownloadLessonUseCase(sl()));
  sl.registerLazySingleton(() => PauseDownloadUseCase(sl()));
  sl.registerLazySingleton(() => ResumeDownloadUseCase(sl()));
  sl.registerLazySingleton(() => CancelDownloadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOfflineCourseUseCase(sl()));
  sl.registerLazySingleton(() => SyncPendingUseCase(sl()));
  sl.registerFactory(
    () => OfflineBloc(
      getOfflineStatus: sl(),
      downloadLesson: sl(),
      pauseDownload: sl(),
      resumeDownload: sl(),
      cancelDownload: sl(),
      deleteOfflineCourse: sl(),
      syncPending: sl(),
      connectivityService: sl(),
      syncService: sl(),
      encryptionService: sl(),
    ),
  );
}
