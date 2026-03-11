import 'package:equatable/equatable.dart';
import '../../domain/entities/discussion_comment.dart';

abstract class DiscussionState extends Equatable {
  const DiscussionState();
  @override
  List<Object?> get props => [];
}

class DiscussionInitial extends DiscussionState {}

class DiscussionLoading extends DiscussionState {}

class DiscussionLoaded extends DiscussionState {
  final List<DiscussionComment> comments;
  final int totalPages;
  final int currentPage;

  const DiscussionLoaded({
    required this.comments,
    this.totalPages = 1,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [comments, totalPages, currentPage];
}

class DiscussionError extends DiscussionState {
  final String message;
  const DiscussionError(this.message);
  @override
  List<Object?> get props => [message];
}

class CommentPosted extends DiscussionState {
  final int commentId;
  const CommentPosted(this.commentId);
  @override
  List<Object?> get props => [commentId];
}
