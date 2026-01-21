import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class CreateClassUseCase {
  final TeacherRepository repository;

  CreateClassUseCase(this.repository);

  Future<Either<Failure, void>> call(
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
  ) async {
    return await repository.createClass(
      className,
      teacherId,
      subjectName,
      room,
      startTime,
      endTime,
      startDate,
      repeatWeeks,
      notificationMinutes,
      credits,
    );
  }
}
