import 'package:dartz/dartz.dart';
import '../repositories/notification_repository.dart';
import '../../../../core/error/failures.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(int userId) async {
    return await repository.markAllNotificationsAsRead(userId);
  }
}
