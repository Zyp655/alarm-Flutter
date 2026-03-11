import '../../domain/entities/discussion_comment.dart';

class DiscussionCommentModel extends DiscussionComment {
  const DiscussionCommentModel({
    required super.id,
    required super.lessonId,
    required super.userId,
    required super.text,
    super.parentId,
    super.depth,
    super.path,
    super.upvotes,
    super.downvotes,
    super.isPinned,
    super.isAnswered,
    super.editedAt,
    required super.createdAt,
    super.userName,
    super.userAvatar,
    super.replies,
    super.myVote,
  });

  factory DiscussionCommentModel.fromJson(Map<String, dynamic> json) {
    final repliesList = json['replies'] as List<dynamic>? ?? [];
    return DiscussionCommentModel(
      id: json['id'] as int,
      lessonId: json['lessonId'] as int,
      userId: json['userId'] as int,
      text: json['content'] as String? ?? '',
      parentId: json['parentId'] as int?,
      depth: json['depth'] as int? ?? 0,
      path: json['path'] as String?,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      isAnswered: json['isAnswered'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.tryParse(json['editedAt'] as String)
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      replies: repliesList
          .map(
            (r) => DiscussionCommentModel.fromJson(r as Map<String, dynamic>),
          )
          .toList(),
      myVote: json['myVote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'userId': userId,
      'content': text,
      'parentId': parentId,
      'depth': depth,
      'path': path,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'isPinned': isPinned,
      'isAnswered': isAnswered,
      'editedAt': editedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'userAvatar': userAvatar,
      'myVote': myVote,
    };
  }
}
