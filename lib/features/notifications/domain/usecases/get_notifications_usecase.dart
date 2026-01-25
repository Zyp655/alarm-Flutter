import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import '../../../../core/error/failures.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    required int userId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    return await repository.getNotifications(
      userId: userId,
      limit: limit,
      offset: offset,
      unreadOnly: unreadOnly,
    );
  }
}
