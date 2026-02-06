import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final int id;
  final int lessonId;
  final int userId;
  final String userName;
  final int userRole;
  final String content;
  final int? parentId;
  final DateTime createdAt;
  final bool isTeacherResponse;

  final String? userAvatarUrl;

  const CommentEntity({
    required this.id,
    required this.lessonId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.isTeacherResponse,
    this.userAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    lessonId,
    userId,
    userName,
    userRole,
    content,
    parentId,
    createdAt,
    isTeacherResponse,
    userAvatarUrl,
  ];
}
