import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
