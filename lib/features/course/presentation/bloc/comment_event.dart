import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCommentsEvent extends CommentEvent {
  final int lessonId;
  const LoadCommentsEvent(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class AddCommentEvent extends CommentEvent {
  final int lessonId;
  final int userId;
  final String content;
  final int? parentId;

  const AddCommentEvent({
    required this.lessonId,
    required this.userId,
    required this.content,
    this.parentId,
  });

  @override
  List<Object?> get props => [lessonId, userId, content, parentId];
}
