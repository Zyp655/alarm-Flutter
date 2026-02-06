import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/course_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CourseRepository repository;

  CommentBloc({required this.repository}) : super(CommentInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final result = await repository.getComments(event.lessonId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentLoaded(comments)),
    );
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    final result = await repository.createComment(
      lessonId: event.lessonId,
      userId: event.userId,
      content: event.content,
      parentId: event.parentId,
    );

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) => add(LoadCommentsEvent(event.lessonId)),
    );
  }
}
