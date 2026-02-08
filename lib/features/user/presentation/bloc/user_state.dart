import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity_extended.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final UserEntityExtended user;
  const UserProfileLoaded(this.user);
  @override
  List<Object> get props => [user];
}

class UserUpdateSuccess extends UserState {
  final String message;
  const UserUpdateSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object> get props => [message];
}
