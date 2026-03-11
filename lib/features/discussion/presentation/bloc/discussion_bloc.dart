import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/discussion_repository.dart';
import '../../domain/usecases/get_discussions_usecase.dart';
import '../../domain/usecases/post_comment_usecase.dart';
import '../../domain/usecases/vote_comment_usecase.dart';
import '../../domain/usecases/moderate_comment_usecase.dart';
import 'discussion_event.dart';
import 'discussion_state.dart';

export 'discussion_event.dart';
export 'discussion_state.dart';

class DiscussionBloc extends Bloc<DiscussionEvent, DiscussionState> {
  final GetDiscussionsUseCase getDiscussions;
  final PostCommentUseCase postComment;
  final VoteCommentUseCase voteComment;
  final ModerateCommentUseCase moderateComment;
  final DiscussionRepository repository;
  int? _currentLessonId;

  DiscussionBloc({
    required this.getDiscussions,
    required this.postComment,
    required this.voteComment,
    required this.moderateComment,
    required this.repository,
  }) : super(DiscussionInitial()) {
    on<LoadDiscussions>(_onLoadDiscussions);
    on<PostComment>(_onPostComment);
    on<VoteComment>(_onVoteComment);
    on<ModerateComment>(_onModerateComment);
    on<RealTimeEvent>(_onRealTimeEvent);
  }

  Future<void> _onLoadDiscussions(
    LoadDiscussions event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(DiscussionLoading());
    _currentLessonId = event.lessonId;

    final result = await getDiscussions(
      lessonId: event.lessonId,
      page: event.page,
    );

    result.fold(
      (failure) => emit(DiscussionError(failure.message)),
      (comments) =>
          emit(DiscussionLoaded(comments: comments, currentPage: event.page)),
    );

    repository
        .connectToLessonRoom(event.lessonId)
        .listen((data) => add(RealTimeEvent(data)));
  }

  Future<void> _onPostComment(
    PostComment event,
    Emitter<DiscussionState> emit,
  ) async {
    final result = await postComment(
      lessonId: event.lessonId,
      userId: event.userId,
      text: event.text,
      parentId: event.parentId,
    );

    result.fold((failure) => emit(DiscussionError(failure.message)), (id) {
      emit(CommentPosted(id));
      add(LoadDiscussions(lessonId: event.lessonId));
    });
  }

  Future<void> _onVoteComment(
    VoteComment event,
    Emitter<DiscussionState> emit,
  ) async {
    await voteComment(
      commentId: event.commentId,
      userId: event.userId,
      voteType: event.voteType,
    );

    if (_currentLessonId != null) {
      add(LoadDiscussions(lessonId: _currentLessonId!));
    }
  }

  Future<void> _onModerateComment(
    ModerateComment event,
    Emitter<DiscussionState> emit,
  ) async {
    await moderateComment(commentId: event.commentId, action: event.action);

    if (_currentLessonId != null) {
      add(LoadDiscussions(lessonId: _currentLessonId!));
    }
  }

  void _onRealTimeEvent(RealTimeEvent event, Emitter<DiscussionState> emit) {
    if (_currentLessonId != null) {
      add(LoadDiscussions(lessonId: _currentLessonId!));
    }
  }

  @override
  Future<void> close() {
    repository.disconnectFromLessonRoom();
    return super.close();
  }
}
