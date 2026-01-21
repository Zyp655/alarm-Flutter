import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../entities/subject_entity.dart';
import '../entities/student_entity.dart';
import '../entities/assignment_entity.dart';

abstract class TeacherRepository {
  Future<Either<Failure, List<AssignmentEntity>>> getAssignments(int teacherId);

  Future<Either<Failure, void>> createAssignment(
    AssignmentEntity assignment,
    int teacherId,
  );
  Future<Either<Failure, void>> createClass(
    String className,
    int teacherId,
    String subjectName,
    String room,
    DateTime startTime,
    DateTime endTime,
    DateTime startDate,
    int repeatWeeks,
    int notificationMinutes,
    int credits,
  );

  Future<Either<Failure, List<ScheduleEntity>>> getAllSchedules(int teacherId);

  Future<Either<Failure, void>> updateScore(
    int scheduleId,
    int? absences,
    double? midtermScore,
    double? finalScore,
  );

  Future<Either<Failure, void>> importSchedules(
    int teacherId,
    List<Map<String, dynamic>> schedules,
  );

  Future<String> regenerateClassCode(
    int teacherId,
    String subjectName,
    bool isRefresh,
  );

  Future<Either<Failure, List<SubjectEntity>>> getSubjects(int teacherId);

  Future<Either<Failure, void>> createSubject(
    int teacherId,
    String name,
    int credits,
    String? code,
  );

  Future<Either<Failure, List<StudentEntity>>> getStudentsInClass(int classId);
}
