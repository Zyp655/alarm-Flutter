import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/course_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateLessonUseCase {
  final CourseRepository repository;

  UpdateLessonUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateLessonParams params) async {
    return await repository.updateLesson(
      courseId: params.courseId,
      moduleId: params.moduleId,
      lessonId: params.lessonId,
      title: params.title,
      type: params.type,
      contentUrl: params.contentUrl,
      textContent: params.textContent,
      durationMinutes: params.durationMinutes,
      isFreePreview: params.isFreePreview,
      orderIndex: params.orderIndex,
    );
  }
}

class UpdateLessonParams extends Equatable {
  final int courseId;
  final int moduleId;
  final int lessonId;
  final String? title;
  final String? type;
  final String? contentUrl;
  final String? textContent;
  final int? durationMinutes;
  final bool? isFreePreview;
  final int? orderIndex;

  const UpdateLessonParams({
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    this.title,
    this.type,
    this.contentUrl,
    this.textContent,
    this.durationMinutes,
    this.isFreePreview,
    this.orderIndex,
  });

  @override
  List<Object?> get props => [
    courseId,
    moduleId,
    lessonId,
    title,
    type,
    contentUrl,
    textContent,
    durationMinutes,
    isFreePreview,
    orderIndex,
  ];
}
