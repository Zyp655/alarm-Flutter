import 'package:dartz/dartz.dart';
import '../repositories/notification_repository.dart';
import '../../../../core/error/failures.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> call(int notificationId) async {
    return await repository.markNotificationAsRead(notificationId);
  }
}
