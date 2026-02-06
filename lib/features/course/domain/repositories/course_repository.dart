import 'package:dartz/dartz.dart';
import '../entities/course_entity.dart';
import '../entities/enrollment_entity.dart';
import '../entities/lesson_progress_entity.dart';
import '../entities/module_entity.dart';
import '../entities/lesson_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/submission_entity.dart';
import '../entities/course_student_entity.dart';
import '../../../../core/error/failures.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    String? search,
    String? level,
    int? instructorId,
    int? majorId,
    bool showUnpublished = false,
  });

  Future<Either<Failure, CourseEntity>> getCourseDetails(
    int courseId, {
    int? userId,
  });

  Future<Either<Failure, List<ModuleEntity>>> getCourseCurriculum(int courseId);

  Future<Either<Failure, CourseEntity>> createCourse({
    required String title,
    required int instructorId,
    String? description,
    String? thumbnailUrl,
    double price = 0.0,
    String level = 'beginner',
  });

  Future<Either<Failure, void>> updateCourse(
    int courseId,
    Map<String, dynamic> updates,
  );

  Future<Either<Failure, void>> deleteCourse(int courseId);

  Future<Either<Failure, ModuleEntity>> createModule({
    required int courseId,
    required String title,
    String? description,
  });

  Future<Either<Failure, LessonEntity>> createLesson({
    required int moduleId,
    required String title,
    String type = 'video',
    String? contentUrl,
    String? textContent,
    int? durationMinutes,
  });

  Future<Either<Failure, void>> updateLesson({
    required int courseId,
    required int moduleId,
    required int lessonId,
    String? title,
    String? type,
    String? contentUrl,
    String? textContent,
    int? durationMinutes,
    bool? isFreePreview,
    int? orderIndex,
  });

  Future<Either<Failure, void>> deleteLesson({
    required int courseId,
    required int moduleId,
    required int lessonId,
  });

  Future<Either<Failure, EnrollmentEntity>> enrollCourse({
    required int userId,
    required int courseId,
  });

  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments(int userId);

  Future<Either<Failure, EnrollmentEntity>> getEnrollment({
    required int userId,
    required int courseId,
  });

  Future<Either<Failure, void>> updateLessonProgress({
    required int userId,
    required int lessonId,
    int lastWatchedPosition = 0,
    bool isCompleted = false,
  });

  Future<Either<Failure, LessonProgressEntity?>> getLessonProgress({
    required int userId,
    required int lessonId,
  });

  Future<Either<Failure, List<CommentEntity>>> getComments(int lessonId);
  Future<Either<Failure, void>> createComment({
    required int lessonId,
    required int userId,
    required String content,
    int? parentId,
  });

  Future<Either<Failure, void>> createSubmission({
    required int assignmentId,
    required int studentId,
    String? textContent,
    String? linkUrl,
  });
  Future<Either<Failure, List<SubmissionEntity>>> getSubmissions(
    int assignmentId,
  );

  Future<Either<Failure, List<CourseStudentEntity>>> getCourseStudents(
    int courseId,
  );
}
