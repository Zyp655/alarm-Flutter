import '../../domain/enitities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    super.id,
    super.userId,
    required super.subject,
    required super.room,
    required super.start,
    required super.end,
    super.note,
    super.imagePath,
    super.currentAbsences = 0,
    super.maxAbsences = 3,
    super.midtermScore,
    super.finalScore,
    super.examScore, 
    super.targetScore = 4.0,
    super.classId,
    super.classCode,
    super.credits = 3,
    super.createdAt,
    super.type = ScheduleType.classSession,
    super.format = ScheduleFormat.offline,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      subject: json['subject'] as String? ?? 'Chưa có tên',
      room: json['room'] as String? ?? '',
      classId: json['classId'] as int?,
      classCode: json['classCode'] as String?,
      credits: json['credits'] as int? ?? 3,
      start:
          DateTime.tryParse(
            json['startTime']?.toString() ?? json['start']?.toString() ?? '',
          ) ??
          DateTime.now(),
      end:
          DateTime.tryParse(
            json['endTime']?.toString() ?? json['end']?.toString() ?? '',
          ) ??
          DateTime.now(),
      note: json['note'] as String?,
      imagePath: json['imagePath'] as String?,
      currentAbsences: json['currentAbsences'] as int? ?? 0,
      maxAbsences: json['maxAbsences'] as int? ?? 3,
      midtermScore: (json['midtermScore'] as num?)?.toDouble(),
      finalScore: (json['finalScore'] as num?)?.toDouble(),
      examScore: (json['examScore'] as num?)?.toDouble(),
      targetScore: (json['targetScore'] as num?)?.toDouble() ?? 4.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      type: _parseType(json['type'] as String?),
      format: _parseFormat(json['format'] as String?),
    );
  }

  static ScheduleType _parseType(String? type) {
    if (type == 'exam') return ScheduleType.exam;
    if (type == 'event') return ScheduleType.event;
    return ScheduleType.classSession;
  }

  static ScheduleFormat _parseFormat(String? format) {
    if (format == 'online') return ScheduleFormat.online;
    return ScheduleFormat.offline;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'room': room,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'note': note,
      'credits': credits,
      'imagePath': imagePath,
      'currentAbsences': currentAbsences,
      'maxAbsences': maxAbsences,
      'midtermScore': midtermScore,
      'finalScore': finalScore,
      'examScore': examScore, 
      'targetScore': targetScore,
      'classId': classId,
      'classCode': classCode,
      'type': type.name,
      'format': format.name, 
    };
  }

  factory ScheduleModel.fromEntity(ScheduleEntity entity) {
    return ScheduleModel(
      id: entity.id,
      userId: entity.userId,
      subject: entity.subject,
      room: entity.room,
      start: entity.start,
      end: entity.end,
      note: entity.note,
      imagePath: entity.imagePath,
      currentAbsences: entity.currentAbsences,
      maxAbsences: entity.maxAbsences,
      midtermScore: entity.midtermScore,
      finalScore: entity.finalScore,
      examScore: entity.examScore, 
      targetScore: entity.targetScore,
      classId: entity.classId,
      classCode: entity.classCode,
      createdAt: entity.createdAt,
      type: entity.type,
      format: entity.format,
    );
  }
}
