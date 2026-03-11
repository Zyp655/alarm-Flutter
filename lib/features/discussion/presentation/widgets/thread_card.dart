import 'package:flutter/material.dart';
import '../../domain/entities/discussion_comment.dart';
import '../../../../core/theme/app_colors.dart';

class ThreadCard extends StatelessWidget {
  final DiscussionComment thread;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final VoidCallback? onTap;

  const ThreadCard({
    super.key,
    required this.thread,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Text(
                thread.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withAlpha(40),
          child: Text(
            (thread.userName ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                thread.userName ?? 'Ẩn danh',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                thread.timeAgo,
                style: TextStyle(color: subTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        if (thread.isPinned) _buildBadge('Ghim', Icons.push_pin, Colors.amber),
        if (thread.isAnswered)
          Padding(
            padding: EdgeInsets.only(left: thread.isPinned ? 6 : 0),
            child: _buildBadge('Đã trả lời', Icons.check_circle, Colors.green),
          ),
      ],
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.thumb_up_alt_outlined, size: 16, color: subTextColor),
        const SizedBox(width: 4),
        Text(
          '${thread.upvotes}',
          style: TextStyle(color: subTextColor, fontSize: 13),
        ),
        const SizedBox(width: 16),
        Icon(Icons.chat_bubble_outline, size: 16, color: subTextColor),
        const SizedBox(width: 4),
        Text(
          '${thread.replies.length} phản hồi',
          style: TextStyle(color: subTextColor, fontSize: 13),
        ),
      ],
    );
  }
}
