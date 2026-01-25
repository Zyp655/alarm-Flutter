import 'package:dartz/dartz.dart';
import '../repositories/notification_repository.dart';
import '../../../../core/error/failures.dart';

class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call(int userId) async {
    return await repository.getUnreadCount(userId);
  }
}
