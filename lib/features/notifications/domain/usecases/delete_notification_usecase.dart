import 'package:dartz/dartz.dart';
import '../repositories/notification_repository.dart';
import '../../../../core/error/failures.dart';

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call(int notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}
