import 'package:get_it/get_it.dart';
import '../features/search/data/datasources/search_remote_datasource.dart';
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/domain/usecases/search_usecase.dart';
import '../features/search/presentation/bloc/search_bloc.dart';

void initSearchModule(GetIt sl) {
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SearchUseCase(sl()));
  sl.registerFactory(() => SearchBloc(searchUseCase: sl(), prefs: sl()));
}
