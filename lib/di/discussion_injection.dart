import 'package:get_it/get_it.dart';
import '../features/discussion/data/datasources/discussion_remote_datasource.dart';
import '../features/discussion/data/repositories/discussion_repository_impl.dart';
import '../features/discussion/data/services/discussion_ws_service.dart';
import '../features/discussion/domain/repositories/discussion_repository.dart';
import '../features/discussion/domain/usecases/get_discussions_usecase.dart';
import '../features/discussion/domain/usecases/post_comment_usecase.dart';
import '../features/discussion/domain/usecases/vote_comment_usecase.dart';
import '../features/discussion/domain/usecases/moderate_comment_usecase.dart';
import '../features/discussion/presentation/bloc/discussion_bloc.dart';

void initDiscussionModule(GetIt sl) {
  sl.registerLazySingleton<DiscussionRemoteDataSource>(
    () => DiscussionRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton(() => DiscussionWsService());
  sl.registerLazySingleton<DiscussionRepository>(
    () => DiscussionRepositoryImpl(remoteDataSource: sl(), wsService: sl()),
  );
  sl.registerLazySingleton(() => GetDiscussionsUseCase(sl()));
  sl.registerLazySingleton(() => PostCommentUseCase(sl()));
  sl.registerLazySingleton(() => VoteCommentUseCase(sl()));
  sl.registerLazySingleton(() => ModerateCommentUseCase(sl()));
  sl.registerFactory(
    () => DiscussionBloc(
      getDiscussions: sl(),
      postComment: sl(),
      voteComment: sl(),
      moderateComment: sl(),
      repository: sl(),
    ),
  );
}
