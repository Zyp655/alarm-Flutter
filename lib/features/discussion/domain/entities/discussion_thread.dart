import 'package:equatable/equatable.dart';

class DiscussionThread extends Equatable {
  final int id;
  final int lessonId;
  final String lessonTitle;
  final int userId;
  final String? userName;
  final String preview;
  final int replyCount;
  final int upvotes;
  final bool isPinned;
  final bool isAnswered;
  final DateTime createdAt;
  final DateTime? lastActivityAt;

  const DiscussionThread({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.userId,
    this.userName,
    required this.preview,
    this.replyCount = 0,
    this.upvotes = 0,
    this.isPinned = false,
    this.isAnswered = false,
    required this.createdAt,
    this.lastActivityAt,
  });

  String get timeAgo {
    final ref = lastActivityAt ?? createdAt;
    final diff = DateTime.now().difference(ref);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    lessonTitle,
    userId,
    userName,
    preview,
    replyCount,
    upvotes,
    isPinned,
    isAnswered,
    createdAt,
    lastActivityAt,
  ];
}
