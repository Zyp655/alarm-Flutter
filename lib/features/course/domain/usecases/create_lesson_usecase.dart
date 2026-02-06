import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lesson_entity.dart';
import '../repositories/course_repository.dart';

class CreateLessonUseCase {
  final CourseRepository repository;

  CreateLessonUseCase(this.repository);

  Future<Either<Failure, LessonEntity>> call(CreateLessonParams params) async {
    return await repository.createLesson(
      moduleId: params.moduleId,
      title: params.title,
      type: params.type,
      contentUrl: params.contentUrl,
      textContent: params.textContent,
      durationMinutes: params.durationMinutes,
    );
  }
}

class CreateLessonParams {
  final int moduleId;
  final String title;
  final String type;
  final String? contentUrl;
  final String? textContent;
  final int? durationMinutes;

  const CreateLessonParams({
    required this.moduleId,
    required this.title,
    this.type = 'video',
    this.contentUrl,
    this.textContent,
    this.durationMinutes,
  });
}
