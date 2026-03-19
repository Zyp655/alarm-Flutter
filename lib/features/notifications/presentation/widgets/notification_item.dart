import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  IconData _getIcon(String type) {
    switch (type) {
      case 'assignment_new':
        return Icons.assignment_rounded;
      case 'assignment_deadline':
        return Icons.alarm_rounded;
      case 'grade_updated':
        return Icons.emoji_events_rounded;
      case 'submission_new':
        return Icons.upload_file_rounded;
      case 'schedule_change':
        return Icons.event_note_rounded;
      case 'quiz_new':
        return Icons.quiz_rounded;
      case 'chat_message':
        return Icons.chat_bubble_rounded;
      case 'absence_warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getAccentColor(String type) {
    switch (type) {
      case 'assignment_new':
        return const Color(0xFF4A90D9);
      case 'assignment_deadline':
        return const Color(0xFFE8854A);
      case 'grade_updated':
        return const Color(0xFF50B86C);
      case 'submission_new':
        return const Color(0xFF9B6CD9);
      case 'schedule_change':
        return const Color(0xFFD94A5E);
      case 'quiz_new':
        return const Color(0xFF3DBAAA);
      case 'chat_message':
        return const Color(0xFF5C7AEA);
      case 'absence_warning':
        return const Color(0xFFD9A54A);
      default:
        return const Color(0xFF8E99A4);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _getAccentColor(notification.type);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? (isUnread ? const Color(0xFF1E2A3A) : AppColors.darkCard)
                    : (isUnread ? accent.withValues(alpha: 0.04) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnread
                      ? accent.withValues(alpha: 0.25)
                      : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.12)),
                ),
                boxShadow: isUnread
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.15),
                          accent.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIcon(notification.type), color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                  color: isDark ? Colors.white : AppColors.darkBackground,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(notification.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
