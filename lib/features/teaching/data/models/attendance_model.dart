import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    super.id,
    required super.classId,
    super.scheduleId,
    required super.studentId,
    required super.date,
    required super.status,
    super.note,
    required super.markedBy,
    required super.markedAt,
    super.updatedAt,
    super.studentName,
    super.studentEmail,
    super.className,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int?,
      classId: json['classId'] as int,
      scheduleId: json['scheduleId'] as int?,
      studentId: json['studentId'] as int,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      note: json['note'] as String?,
      markedBy: json['markedBy'] as int,
      markedAt: DateTime.parse(json['markedAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      studentName: json['studentName'] as String?,
      studentEmail: json['studentEmail'] as String?,
      className: json['className'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'scheduleId': scheduleId,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'status': status,
      'note': note,
      'markedBy': markedBy,
      'markedAt': markedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'studentName': studentName,
      'studentEmail': studentEmail,
      'className': className,
    };
  }

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      id: entity.id,
      classId: entity.classId,
      scheduleId: entity.scheduleId,
      studentId: entity.studentId,
      date: entity.date,
      status: entity.status,
      note: entity.note,
      markedBy: entity.markedBy,
      markedAt: entity.markedAt,
      updatedAt: entity.updatedAt,
      studentName: entity.studentName,
      studentEmail: entity.studentEmail,
      className: entity.className,
    );
  }
}
