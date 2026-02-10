import 'package:dartz/dartz.dart';
import '../entities/attendance_entity.dart';
import '../../../../core/error/failures.dart';

import '../repositories/teacher_repository.dart';

class GetStudentAttendanceUseCase {
  final TeacherRepository repository;

  GetStudentAttendanceUseCase(this.repository);

  Future<Either<Failure, List<AttendanceEntity>>> call({
    required int userId,
    int? classId,
  }) async {
    throw UnimplementedError();
  }
}
