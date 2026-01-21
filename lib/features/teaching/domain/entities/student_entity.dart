import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  final int scheduleId;
  final int userId;
  final String studentName;
  final String studentId;
  final String email;
  final int currentAbsences;
  final int maxAbsences;
  final double? midtermScore;
  final double? finalScore;
  final double targetScore;

  const StudentEntity({
    required this.scheduleId,
    required this.userId,
    required this.studentName,
    required this.studentId,
    required this.email,
    required this.currentAbsences,
    required this.maxAbsences,
    this.midtermScore,
    this.finalScore,
    required this.targetScore,
  });

  @override
  List<Object?> get props => [
    scheduleId,
    userId,
    studentName,
    studentId,
    email,
    currentAbsences,
    maxAbsences,
    midtermScore,
    finalScore,
    targetScore,
  ];
}
