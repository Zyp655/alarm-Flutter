import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int userId;
  final bool unreadOnly;

  const LoadNotifications({required this.userId, this.unreadOnly = false});

  @override
  List<Object?> get props => [userId, unreadOnly];
}

class MarkNotificationRead extends NotificationEvent {
  final int notificationId;

  const MarkNotificationRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsRead extends NotificationEvent {
  final int userId;

  const MarkAllNotificationsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteNotification extends NotificationEvent {
  final int notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class RefreshNotifications extends NotificationEvent {
  final int userId;

  const RefreshNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}
