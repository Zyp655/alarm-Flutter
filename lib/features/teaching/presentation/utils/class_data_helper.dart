import '../../../schedule/domain/enitities/schedule_entity.dart';

class ClassData {
  final List<ScheduleEntity> students;
  final String? classCode;
  final String? room;

  ClassData(this.students, this.classCode, this.room);
}

class ClassDataHelper {
  static ClassData extract({
    required List<ScheduleEntity> sourceData,
    required String subjectName,
    required int? currentTeacherId,
  }) {
    if (currentTeacherId == null) return ClassData([], null, null);

    final subjectSchedules = sourceData
        .where((s) => s.subject == subjectName)
        .toList();

    if (subjectSchedules.isEmpty) return ClassData([], null, null);

    String? classCode;
    final scheduleWithCode = subjectSchedules
        .where((s) => s.classCode != null && s.classCode!.isNotEmpty);

    if (scheduleWithCode.isNotEmpty) {
      classCode = scheduleWithCode.first.classCode;
    } else {
      classCode = subjectSchedules.first.classCode;
    }

    // 3. Tìm phòng học
    String? room = subjectSchedules.first.room;

    // 4. Lọc danh sách sinh viên (Loại bỏ giáo viên và trùng lặp ID)
    final Map<int, ScheduleEntity> studentMap = {};
    for (var schedule in subjectSchedules) {
      if (schedule.userId == null || schedule.userId == currentTeacherId) {
        continue;
      }
      studentMap[schedule.userId!] = schedule;
    }

    return ClassData(studentMap.values.toList(), classCode, room);
  }
}