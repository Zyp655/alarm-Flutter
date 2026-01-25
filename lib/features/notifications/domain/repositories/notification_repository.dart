import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';
import '../../../../core/error/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required int userId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  });

  Future<Either<Failure, void>> markNotificationAsRead(int notificationId);

  Future<Either<Failure, void>> markAllNotificationsAsRead(int userId);

  Future<Either<Failure, void>> deleteNotification(int notificationId);

  Future<Either<Failure, int>> getUnreadCount(int userId);
}
