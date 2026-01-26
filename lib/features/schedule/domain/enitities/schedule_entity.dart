import 'package:equatable/equatable.dart';

enum ScheduleType { classSession, exam, event }

enum ScheduleFormat { offline, online }

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
  final double? examScore;
  final int? userId;
  final int? classId;
  final String? classCode;
  final int credits;
  final DateTime? createdAt;
  final ScheduleType type;
  final ScheduleFormat format;

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
    this.examScore,
    this.userId,
    this.classId,
    this.classCode,
    this.credits = 3,
    this.createdAt,
    this.type = ScheduleType.classSession,
    this.format = ScheduleFormat.offline,
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
    examScore,
    credits,
    createdAt,
    type,
    format,
  ];
}
