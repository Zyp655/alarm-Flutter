import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class DeleteCourseClassUseCase {
  final AdminRepository repository;
  DeleteCourseClassUseCase(this.repository);

  Future<Either<Failure, String>> call(int courseClassId) {
    return repository.deleteCourseClass(courseClassId);
  }
}
