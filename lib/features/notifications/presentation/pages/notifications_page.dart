import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/common/animated_widgets.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../course/presentation/pages/course_submissions_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      context.read<NotificationBloc>().add(
        LoadNotifications(userId: authState.user!.id),
      );
    }
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      context.read<NotificationBloc>().add(
        RefreshNotifications(authState.user!.id),
      );
    }
  }

  void _markAllAsRead() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      context.read<NotificationBloc>().add(
        MarkAllNotificationsRead(authState.user!.id),
      );
    }
  }

  void _handleNotificationTap(dynamic notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationRead(notification.id!),
      );
    }

    switch (notification.type) {
      case 'assignment_new':
      case 'assignment_deadline':
        if (notification.relatedId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseSubmissionsPage(
                assignmentId: notification.relatedId!,
                assignmentTitle: notification.title ?? 'Bài tập',
              ),
            ),
          );
        }
        break;
      case 'grade_updated':
        if (notification.relatedId != null) {
          context.push('/courses/${notification.relatedId}');
        }
        break;
      case 'new_course':
      case 'course_completed':
      case 'learning_reminder':
        if (notification.relatedId != null) {
          context.push('/courses/${notification.relatedId}');
        } else {
          context.push('/courses');
        }
        break;
      case 'new_lesson':
        if (notification.relatedId != null) {
          context.push('/courses/${notification.relatedId}');
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: isDark ? Colors.white : AppColors.darkBackground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông Báo',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: isDark ? Colors.white : AppColors.darkBackground,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_all_rounded,
              size: 22,
              color: AppColors.primary,
            ),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _markAllAsRead,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is NotificationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: ShimmerCard(height: 90),
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PulseWidget(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off_rounded,
                          size: 36,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Chưa có thông báo nào',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        'Bạn sẽ nhận thông báo tại đây',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final unreadCount = state.notifications.where((n) => !n.isRead).length;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: state.notifications.length + (unreadCount > 0 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (unreadCount > 0 && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$unreadCount chưa đọc',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final notifIndex = unreadCount > 0 ? index - 1 : index;
                    final notification = state.notifications[notifIndex];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: NotificationItem(
                            notification: notification,
                            onTap: () => _handleNotificationTap(notification),
                            onDelete: () {
                              context.read<NotificationBloc>().add(
                                DeleteNotification(notification.id!),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 32,
                        color: AppColors.error.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _loadNotifications,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Thử lại'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
