import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/common/animated_widgets.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/notification_item.dart';

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

    // Navigation logic
    switch (notification.type) {
      case 'assignment_new':
      case 'assignment_deadline':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chức năng xem chi tiết bài tập (ID: ${notification.relatedId}) đang phát triển',
            ),
          ),
        );
        break;
      case 'grade_updated':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chức năng xem điểm (ID: ${notification.relatedId}) đang phát triển',
            ),
          ),
        );
        break;
      case 'new_course':
      case 'course_completed':
      case 'learning_reminder':
        if (notification.relatedId != null) {
          Navigator.pushNamed(
            context,
            '/courses/detail',
            arguments: notification.relatedId,
          );
        } else {
          Navigator.pushNamed(context, '/courses');
        }
        break;
      case 'new_lesson':
        if (notification.relatedId != null) {
          Navigator.pushNamed(
            context,
            '/courses/detail',
            arguments: notification.relatedId,
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotificationActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerCard(height: 100),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PulseWidget(
                      child: Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Chưa có thông báo nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: NotificationItem(
                            notification: notification,
                            onTap: () {
                              _handleNotificationTap(notification);
                            },
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
