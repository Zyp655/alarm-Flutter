import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class AttendanceStatistics {
  final int studentId;
  final String studentName;
  final String studentEmail;
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double attendanceRate;

  AttendanceStatistics({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.attendanceRate,
  });
}

class GetAttendanceStatisticsUseCase {
  final TeacherRepository repository;

  GetAttendanceStatisticsUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(int classId) async {
    return await repository.getAttendanceStatistics(classId);
  }
}
