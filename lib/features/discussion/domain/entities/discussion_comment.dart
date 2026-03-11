import 'package:equatable/equatable.dart';

class DiscussionComment extends Equatable {
  final int id;
  final int lessonId;
  final int userId;
  final String text;
  final int? parentId;
  final int depth;
  final String? path;
  final int upvotes;
  final int downvotes;
  final bool isPinned;
  final bool isAnswered;
  final DateTime? editedAt;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
  final List<DiscussionComment> replies;
  final String? myVote;

  const DiscussionComment({
    required this.id,
    required this.lessonId,
    required this.userId,
    required this.text,
    this.parentId,
    this.depth = 0,
    this.path,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isPinned = false,
    this.isAnswered = false,
    this.editedAt,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.replies = const [],
    this.myVote,
  });

  int get score => upvotes - downvotes;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  DiscussionComment copyWith({
    int? upvotes,
    int? downvotes,
    bool? isPinned,
    bool? isAnswered,
    List<DiscussionComment>? replies,
    String? myVote,
  }) {
    return DiscussionComment(
      id: id,
      lessonId: lessonId,
      userId: userId,
      text: text,
      parentId: parentId,
      depth: depth,
      path: path,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      isPinned: isPinned ?? this.isPinned,
      isAnswered: isAnswered ?? this.isAnswered,
      editedAt: editedAt,
      createdAt: createdAt,
      userName: userName,
      userAvatar: userAvatar,
      replies: replies ?? this.replies,
      myVote: myVote ?? this.myVote,
    );
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    userId,
    text,
    parentId,
    depth,
    path,
    upvotes,
    downvotes,
    isPinned,
    isAnswered,
    editedAt,
    createdAt,
    replies,
    myVote,
  ];
}
