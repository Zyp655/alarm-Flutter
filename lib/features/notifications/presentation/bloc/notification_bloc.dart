import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../../domain/entities/notification_entity.dart';


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotifications;
  final MarkNotificationReadUseCase markNotificationRead;
  final MarkAllNotificationsReadUseCase markAllNotificationsRead;
  final DeleteNotificationUseCase deleteNotification;
  final GetUnreadCountUseCase getUnreadCount;

  NotificationBloc({
    required this.getNotifications,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
    required this.deleteNotification,
    required this.getUnreadCount,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
    on<MarkAllNotificationsRead>(_onMarkAllNotificationsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await getNotifications(
      userId: event.userId,
      unreadOnly: event.unreadOnly,
    );

    await result.fold(
      (failure) async => emit(NotificationError(failure.message)),
      (notifications) async {
        final countResult = await getUnreadCount(event.userId);
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        emit(
          NotificationsLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markNotificationRead(event.notificationId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((notif) {
          if (notif.id == event.notificationId) {
            return NotificationEntity(
              id: notif.id,
              userId: notif.userId,
              type: notif.type,
              title: notif.title,
              message: notif.message,
              isRead: true,
              actionUrl: notif.actionUrl,
              relatedId: notif.relatedId,
              relatedType: notif.relatedType,
              createdAt: notif.createdAt,
            );
          }
          return notif;
        }).toList();

        final newUnreadCount = currentState.unreadCount > 0
            ? currentState.unreadCount - 1
            : 0;

        emit(
          NotificationsLoaded(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ),
        );
      }
    });
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAllNotificationsRead(event.userId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((notif) {
          return NotificationEntity(
            id: notif.id,
            userId: notif.userId,
            type: notif.type,
            title: notif.title,
            message: notif.message,
            isRead: true,
            actionUrl: notif.actionUrl,
            relatedId: notif.relatedId,
            relatedType: notif.relatedType,
            createdAt: notif.createdAt,
          );
        }).toList();

        emit(
          NotificationsLoaded(
            notifications: updatedNotifications,
            unreadCount: 0,
          ),
        );
        emit(const NotificationActionSuccess('Đã đánh dấu tất cả đã đọc'));
      }
    });
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await deleteNotification(event.notificationId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications
            .where((notif) => notif.id != event.notificationId)
            .toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(
          NotificationsLoaded(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ),
        );
      }
    });
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await getNotifications(
      userId: event.userId,
      unreadOnly: false,
    );

    result.fold(
      (failure) {}, 
      (notifications) async {
        final countResult = await getUnreadCount(event.userId);
        final unreadCount = countResult.fold((failure) => 0, (count) => count);

        emit(
          NotificationsLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }
}
