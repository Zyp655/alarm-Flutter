import '../../domain/entities/user_entity.dart';
import '../../../../core/error/failures.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity? user;

  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final Failure failure;
  AuthFailure(this.failure);
}
