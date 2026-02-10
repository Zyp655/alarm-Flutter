import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class UpdateStudentScoreUseCase {
  final TeacherRepository repository;

  UpdateStudentScoreUseCase(this.repository);

  Future<Either<Failure, void>> call(
    int scheduleId,
    int? absences,
    double? midtermScore,
    double? finalScore,
    double? examScore,
  ) async {
    return await repository.updateScore(
      scheduleId,
      absences,
      midtermScore,
      finalScore,
      examScore,
    );
  }
}
