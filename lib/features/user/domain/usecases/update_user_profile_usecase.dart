import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';
import '../entities/user_entity_extended.dart';

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(UserEntityExtended user) async {
    return await repository.updateUserProfile(user);
  }
}
