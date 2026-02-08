import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity_extended.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntityExtended>> getUserProfile(int userId);
  Future<Either<Failure, void>> updateUserProfile(UserEntityExtended user);
}
