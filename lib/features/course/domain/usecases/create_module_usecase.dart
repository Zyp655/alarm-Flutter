import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/module_entity.dart';
import '../repositories/course_repository.dart';

class CreateModuleUseCase {
  final CourseRepository repository;

  CreateModuleUseCase(this.repository);

  Future<Either<Failure, ModuleEntity>> call(CreateModuleParams params) async {
    return await repository.createModule(
      courseId: params.courseId,
      title: params.title,
      description: params.description,
    );
  }
}

class CreateModuleParams {
  final int courseId;
  final String title;
  final String? description;

  const CreateModuleParams({
    required this.courseId,
    required this.title,
    this.description,
  });
}
