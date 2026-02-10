import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import '../repositories/teacher_repository.dart';

class MarkAttendanceUseCase {
  final TeacherRepository repository;

  MarkAttendanceUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int classId,
    required DateTime date,
    required int teacherId,
    required List<Map<String, dynamic>> attendances,
  }) async {
    return await repository.markAttendance(
      classId: classId,
      date: date,
      teacherId: teacherId,
      attendances: attendances,
    );
  }
}
