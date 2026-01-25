import 'package:dartz/dartz.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required int userId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        userId: userId,
        limit: limit,
        offset: offset,
        unreadOnly: unreadOnly,
      );
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      await remoteDataSource.markNotificationAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead(int userId) async {
    try {
      await remoteDataSource.markAllNotificationsAsRead(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(int userId) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
