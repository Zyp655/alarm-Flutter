import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

class TeacherRepository {
  final AppDatabase db;

  TeacherRepository(this.db);

  Future<bool> updateStudentResult({
    required int scheduleId,
    int? absences,
    double? midtermScore,
    double? finalScore,
  }) async {
    final updateStatement = db.update(db.schedules)
      ..where((t) => t.id.equals(scheduleId));

    await updateStatement.write(
      SchedulesCompanion(
        currentAbsences:
            absences != null ? Value(absences) : const Value.absent(),
        midtermScore:
            midtermScore != null ? Value(midtermScore) : const Value.absent(),
        finalScore:
            finalScore != null ? Value(finalScore) : const Value.absent(),
      ),
    );
    return true;
  }

  Future<List<Schedule>> getAllStudentSchedules() async {
    return await db.select(db.schedules).get();
  }
}
