import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class ImportSchedulesUseCase {
  final TeacherRepository repository;

  ImportSchedulesUseCase(this.repository);

  Future<Either<Failure, void>> call(
    int teacherId,
    List<Map<String, dynamic>> schedules,
  ) async {
    return await repository.importSchedules(teacherId, schedules);
  }
}
