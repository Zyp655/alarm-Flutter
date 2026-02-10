import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

import '../repositories/teacher_repository.dart';

class GetAttendanceRecordsUseCase {
  final TeacherRepository repository;

  GetAttendanceRecordsUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required int classId,
    required DateTime date,
  }) async {
    return await repository.getAttendanceRecords(classId: classId, date: date);
  }
}
