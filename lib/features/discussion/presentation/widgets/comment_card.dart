import 'package:flutter/material.dart';
import '../../domain/entities/discussion_comment.dart';
import '../bloc/discussion_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class CommentCard extends StatelessWidget {
  final DiscussionComment comment;
  final bool isDark;
  final bool isRoot;
  final int currentUserId;
  final VoidCallback? onReply;

  const CommentCard({
    super.key,
    required this.comment,
    required this.isDark,
    this.isRoot = false,
    required this.currentUserId,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final indent = isRoot ? 0.0 : (comment.depth * 16.0).clamp(0.0, 48.0);

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: comment.isPinned
              ? Border.all(color: AppColors.warning, width: 1.5)
              : comment.isAnswered
              ? Border.all(color: const Color(0xFF39D353), width: 1.5)
              : null,
          boxShadow: isRoot
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 51 : 10),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Text(
              comment.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildActions(context),
            if (comment.replies.isNotEmpty) ...[
              if (comment.depth < 3)
                ...comment.replies.map(
                  (reply) => CommentCard(
                    comment: reply,
                    isDark: isDark,
                    currentUserId: currentUserId,
                    onReply: onReply,
                  ),
                )
              else
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Xem ${comment.replies.length} phản hồi khác →',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: _avatarColor(comment.userId),
          child: Text(
            (comment.userName ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.userName ?? 'User ${comment.userId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (comment.isPinned) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.push_pin,
                      size: 14,
                      color: AppColors.warning,
                    ),
                  ],
                  if (comment.isAnswered) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFF39D353),
                    ),
                  ],
                ],
              ),
              Text(
                comment.timeAgo,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        VoteButton(
          icon: Icons.arrow_upward,
          count: comment.upvotes,
          isActive: comment.myVote == 'up',
          activeColor: AppColors.primary,
          onTap: () => context.read<DiscussionBloc>().add(
            VoteComment(
              commentId: comment.id,
              userId: currentUserId,
              voteType: 'up',
            ),
          ),
        ),
        const SizedBox(width: 4),
        VoteButton(
          icon: Icons.arrow_downward,
          count: comment.downvotes,
          isActive: comment.myVote == 'down',
          activeColor: AppColors.error,
          onTap: () => context.read<DiscussionBloc>().add(
            VoteComment(
              commentId: comment.id,
              userId: currentUserId,
              voteType: 'down',
            ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onReply,
          icon: Icon(Icons.reply, size: 16),
          label: const Text('Reply', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }

  static Color _avatarColor(int userId) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      Color(0xFF39D353),
      AppColors.error,
      AppColors.accent,
      AppColors.secondary,
    ];
    return colors[userId % colors.length];
  }
}

class VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const VoteButton({
    super.key,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? activeColor : Colors.grey),
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? activeColor : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
