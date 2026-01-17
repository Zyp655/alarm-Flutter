import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

class StudentRepository {
  final AppDatabase db;

  StudentRepository(this.db);

  Future<StudentProfile?> getProfile(int userId) async {
    return await (db.select(db.studentProfiles)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> updateProfile(
      int userId, String name, String studentId, String major) async {
    final existing = await getProfile(userId);

    if (existing == null) {
      await db.into(db.studentProfiles).insert(StudentProfilesCompanion.insert(
            userId: userId,
            fullName: name,
            studentId: Value(studentId),
            major: Value(major),
          ));
    } else {
      await (db.update(db.studentProfiles)
            ..where((t) => t.userId.equals(userId)))
          .write(
        StudentProfilesCompanion(
          fullName: Value(name),
          studentId: Value(studentId),
          major: Value(major),
        ),
      );
    }
  }

  Future<void> addSchedule(int userId, String subject, DateTime start,
      DateTime end, String room) async {
    await db.into(db.schedules).insert(SchedulesCompanion.insert(
          userId: userId,
          subjectName: subject,
          startTime: start,
          endTime: end,
          room: Value(room),
        ));
  }

  Future<List<Schedule>> getSchedules(int userId) async {
    return await (db.select(db.schedules)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime)]))
        .get();
  }

  Future<int> deleteSchedule(int userId, int scheduleId) {
    return (db.delete(db.schedules)
          ..where((t) => t.id.equals(scheduleId) & t.userId.equals(userId)))
        .go();
  }

  Future<bool> updateSchedule({
    required int userId,
    required int scheduleId,
    required String subject,
    required String room,
    required DateTime start,
    required DateTime end,
    String? note,
    String? imagePath,
    int? currentAbsences,
    int? maxAbsences,
  }) async {
    final result = await (db.update(db.schedules)
          ..where((t) => t.id.equals(scheduleId) & t.userId.equals(userId)))
        .write(
      SchedulesCompanion(
        subjectName: Value(subject),
        room: Value(room),
        startTime: Value(start),
        endTime: Value(end),
        note: note != null ? Value(note) : const Value.absent(),
        imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
        currentAbsences: currentAbsences != null
            ? Value(currentAbsences)
            : const Value.absent(),
        maxAbsences:
            maxAbsences != null ? Value(maxAbsences) : const Value.absent(),
      ),
    );
    return result > 0;
  }
}
