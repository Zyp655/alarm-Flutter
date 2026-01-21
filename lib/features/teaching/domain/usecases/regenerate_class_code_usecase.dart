import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/teacher_repository.dart';

class RegenerateClassCodeUseCase {
  final TeacherRepository repository;

  RegenerateClassCodeUseCase(this.repository);

  Future<Either<Failure, String>> call(int teacherId, String subjectName, bool isRefresh) async {
    try {
      final code = await repository.regenerateClassCode(teacherId, subjectName, isRefresh);
      return Right(code);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}