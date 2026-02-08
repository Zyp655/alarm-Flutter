import '../../domain/entities/user_entity_extended.dart';

class UserModel extends UserEntityExtended {
  const UserModel({
    required int id,
    required String email,
    String? fullName,
    int role = 0,
    String? token,
    String? className,
    String? studentId,
    String? department,
    String? teacherId,
  }) : super(
         id: id,
         email: email,
         fullName: fullName,
         role: role,
         token: token,
         className: className,
         studentId: studentId,
         department: department,
         teacherId: teacherId,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'] ?? 0,
      token: json['token'],
      className: json['className'],
      studentId: json['studentId'],
      department: json['department'],
      teacherId: json['teacherId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'token': token,
      'className': className,
      'studentId': studentId,
      'department': department,
      'teacherId': teacherId,
    };
  }
}
