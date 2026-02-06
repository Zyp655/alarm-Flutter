import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.lessonId,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.content,
    super.parentId,
    required super.createdAt,
    required super.isTeacherResponse,
    super.userAvatarUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      lessonId: json['lessonId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String? ?? 'Unknown',
      userRole: json['userRole'] as int? ?? 0,
      content: json['content'] as String,
      parentId: json['parentId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isTeacherResponse: json['isTeacherResponse'] as bool? ?? false,
      userAvatarUrl: json['userAvatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'content': content,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'isTeacherResponse': isTeacherResponse,
      'userAvatarUrl': userAvatarUrl,
    };
  }
}
