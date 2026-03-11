import 'package:equatable/equatable.dart';

abstract class DiscussionEvent extends Equatable {
  const DiscussionEvent();
  @override
  List<Object?> get props => [];
}

class LoadDiscussions extends DiscussionEvent {
  final int lessonId;
  final int page;
  const LoadDiscussions({required this.lessonId, this.page = 1});
  @override
  List<Object?> get props => [lessonId, page];
}

class PostComment extends DiscussionEvent {
  final int lessonId;
  final int userId;
  final String text;
  final int? parentId;
  const PostComment({
    required this.lessonId,
    required this.userId,
    required this.text,
    this.parentId,
  });
  @override
  List<Object?> get props => [lessonId, userId, text, parentId];
}

class VoteComment extends DiscussionEvent {
  final int commentId;
  final int userId;
  final String voteType;
  const VoteComment({
    required this.commentId,
    required this.userId,
    required this.voteType,
  });
  @override
  List<Object?> get props => [commentId, userId, voteType];
}

class ModerateComment extends DiscussionEvent {
  final int commentId;
  final String action;
  const ModerateComment({required this.commentId, required this.action});
  @override
  List<Object?> get props => [commentId, action];
}

class RealTimeEvent extends DiscussionEvent {
  final Map<String, dynamic> data;
  const RealTimeEvent(this.data);
  @override
  List<Object?> get props => [data];
}
