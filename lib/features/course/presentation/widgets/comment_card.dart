import 'package:flutter/material.dart';
import '../../domain/entities/comment_entity.dart';


class CommentCard extends StatelessWidget {
  final CommentEntity comment;
  final bool isTeacher;
  final VoidCallback? onReply;
  final VoidCallback? onLike;
  final bool isReply;
  final int depth;

  const CommentCard({
    super.key,
    required this.comment,
    this.isTeacher = false,
    this.onReply,
    this.onLike,
    this.isReply = false,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 20.0 + (depth * 16.0) : 0,
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTeacher
            ? const Color(0xFF6C63FF).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isTeacher
            ? Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2))
            : null,
        boxShadow: isTeacher
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isTeacher
                    ? const Color(0xFF6C63FF)
                    : Colors.grey[200],
                backgroundImage: comment.userAvatarUrl != null
                    ? NetworkImage(comment.userAvatarUrl!)
                    : null,
                child: comment.userAvatarUrl == null
                    ? Text(
                        comment.userName.isNotEmpty
                            ? comment.userName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: isTeacher ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isTeacher
                                ? const Color(0xFF6C63FF)
                                : Colors.grey[800],
                          ),
                        ),
                        if (isTeacher) ...[
                          const SizedBox(width: 6),
                          _buildTeacherBadge(),
                        ],
                        const Spacer(),
                        Text(
                          _formatTimestamp(comment.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (onLike != null)
                          _buildActionButton(
                            icon: Icons.thumb_up_outlined,
                            label: 'Thích',
                            onTap: onLike,
                          ),
                        const SizedBox(width: 16),
                        if (onReply != null)
                          _buildActionButton(
                            icon: Icons.reply,
                            label: 'Trả lời',
                            onTap: onReply,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'Giảng viên',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
