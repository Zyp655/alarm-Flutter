import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';
import '../entities/user_entity_extended.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserEntityExtended>> call(int userId) async {
    return await repository.getUserProfile(userId);
  }
}
