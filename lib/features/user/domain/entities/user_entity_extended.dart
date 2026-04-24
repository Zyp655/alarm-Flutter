import '../../../auth/domain/entities/user_entity.dart';

class UserEntityExtended extends UserEntity {
  final String? className;
  final String? studentId;
  final String? department;
  final String? teacherId;
  final String? major;
  final String? academicYear;

  const UserEntityExtended({
    required int id,
    required String email,
    String? fullName,
    int role = 0,
    String? token,
    this.className,
    this.studentId,
    this.department,
    this.teacherId,
    this.major,
    this.academicYear,
  }) : super(
         id: id,
         email: email,
         fullName: fullName,
         role: role,
         token: token,
       );

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    role,
    token,
    className,
    studentId,
    department,
    teacherId,
    major,
    academicYear,
  ];
}
