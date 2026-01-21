import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../repositories/teacher_repository.dart';

class GetTeacherSchedulesUseCase {
  final TeacherRepository repository;

  GetTeacherSchedulesUseCase(this.repository);

  Future<Either<Failure, List<ScheduleEntity>>> call(int teacherId) async {
    return await repository.getAllSchedules(teacherId);
  }
}
