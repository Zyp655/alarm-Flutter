import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CommentComposer extends StatelessWidget {
  final TextEditingController textController;
  final bool isDark;
  final bool isReplying;
  final VoidCallback onSend;
  final VoidCallback? onCancelReply;

  const CommentComposer({
    super.key,
    required this.textController,
    required this.isDark,
    this.isReplying = false,
    required this.onSend,
    this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReplying)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Đang trả lời...',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onCancelReply,
                      child: Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: isReplying
                          ? 'Viết phản hồi...'
                          : 'Viết bình luận...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withAlpha(13)
                          : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: onSend,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
