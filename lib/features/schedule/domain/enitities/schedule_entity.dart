import 'package:equatable/equatable.dart';

class ScheduleEntity extends Equatable {
  final int? id;
  final String subject;
  final String room;
  final DateTime start;
  final DateTime end;
  final String? note;
  final String? imagePath;
  final int currentAbsences;
  final int maxAbsences;
  final double? currentScore;
  final double targetScore;
  final double? midtermScore;
  final double? finalScore;
  final int? userId;
  final int? classId;
  final String? classCode;
  final int credits;
  final DateTime? createdAt;

  const ScheduleEntity({
    this.id,
    required this.subject,
    required this.room,
    required this.start,
    required this.end,
    this.note,
    this.imagePath,
    this.currentAbsences = 0,
    this.maxAbsences = 3,
    this.currentScore,
    this.targetScore = 4.0,
    this.midtermScore,
    this.finalScore,
    this.userId,
    this.classId,
    this.classCode,
    this.credits = 3,
    this.createdAt,
  });

  bool get isFailRisk => (currentScore ?? 10.0) < targetScore;
  bool get isBannedRisk => currentAbsences >= maxAbsences;

  @override
  List<Object?> get props => [
    id,
    userId,
    classId,
    subject,
    room,
    start,
    end,
    classCode,
    currentAbsences,
    midtermScore,
    finalScore,
    credits,
    createdAt,
  ];
}
