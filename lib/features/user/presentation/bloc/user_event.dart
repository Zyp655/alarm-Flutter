import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity_extended.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserEvent {
  final int userId;
  const LoadUserProfile(this.userId);
  @override
  List<Object> get props => [userId];
}

class UpdateUserProfile extends UserEvent {
  final UserEntityExtended user;
  const UpdateUserProfile(this.user);
  @override
  List<Object> get props => [user];
}
