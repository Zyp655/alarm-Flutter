import 'package:flutter/material.dart';

class DiscussionEmptyState extends StatelessWidget {
  final bool isDark;
  final bool isSearchResult;

  const DiscussionEmptyState({
    super.key,
    required this.isDark,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearchResult ? 'Không tìm thấy kết quả' : 'Chưa có thảo luận nào',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchResult
                ? 'Thử tìm với từ khóa khác'
                : 'Hãy là người đầu tiên đặt câu hỏi!',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
