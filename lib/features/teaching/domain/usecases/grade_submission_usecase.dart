import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class GradeSubmissionUseCase {
  final TeacherRepository repository;

  GradeSubmissionUseCase(this.repository);

  Future<Either<Failure, void>> call(
    int submissionId,
    double grade,
    String? feedback,
    int teacherId,
  ) async {
    return await repository.gradeSubmission(
      submissionId,
      grade,
      feedback,
      teacherId,
    );
  }
}
