import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String? fullName;
  final int role;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.role = 0,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, token];
}