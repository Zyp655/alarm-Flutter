import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final int? id;
  final int classId;
  final int? scheduleId;
  final int studentId;
  final DateTime date;
  final String status;
  final String? note;
  final int markedBy;
  final DateTime markedAt;
  final DateTime? updatedAt;

  final String? studentName;
  final String? studentEmail;
  final String? className;

  const AttendanceEntity({
    this.id,
    required this.classId,
    this.scheduleId,
    required this.studentId,
    required this.date,
    required this.status,
    this.note,
    required this.markedBy,
    required this.markedAt,
    this.updatedAt,
    this.studentName,
    this.studentEmail,
    this.className,
  });

  @override
  List<Object?> get props => [
    id,
    classId,
    scheduleId,
    studentId,
    date,
    status,
    note,
    markedBy,
    markedAt,
    updatedAt,
    studentName,
    studentEmail,
    className,
  ];
}
