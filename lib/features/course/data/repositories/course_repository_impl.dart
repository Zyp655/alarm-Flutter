import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/entities/lesson_progress_entity.dart';
import '../../domain/entities/module_entity.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/submission_entity.dart';
import '../../domain/entities/course_student_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    String? search,
    String? level,
    int? instructorId,
    int? majorId,
    bool showUnpublished = false,
  }) async {
    try {
      final courses = await remoteDataSource.getCourses(
        search: search,
        level: level,
        instructorId: instructorId,
        majorId: majorId,
        showUnpublished: showUnpublished,
      );
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseDetails(
    int courseId, {
    int? userId,
  }) async {
    try {
      final course = await remoteDataSource.getCourseDetails(
        courseId,
        userId: userId,
      );
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ModuleEntity>>> getCourseCurriculum(
    int courseId,
  ) async {
    try {
      final modules = await remoteDataSource.getCourseCurriculum(courseId);
      return Right(modules);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> createCourse({
    required String title,
    required int instructorId,
    String? description,
    String? thumbnailUrl,
    double price = 0.0,
    String level = 'beginner',
  }) async {
    try {
      final courseData = {
        'title': title,
        'instructorId': instructorId,
        if (description != null) 'description': description,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'price': price,
        'level': level,
      };
      final course = await remoteDataSource.createCourse(courseData);
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCourse(
    int courseId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await remoteDataSource.updateCourse(courseId, updates);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(int courseId) async {
    try {
      await remoteDataSource.deleteCourse(courseId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ModuleEntity>> createModule({
    required int courseId,
    required String title,
    String? description,
  }) async {
    try {
      final data = {
        'courseId': courseId,
        'title': title,
        'description': description,
      };
      final module = await remoteDataSource.createModule(data);
      return Right(module);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> createLesson({
    required int moduleId,
    required String title,
    String type = 'video',
    String? contentUrl,
    String? textContent,
    int? durationMinutes,
  }) async {
    try {
      final data = {
        'moduleId': moduleId,
        'title': title,
        'type': type,
        'contentUrl': contentUrl,
        'textContent': textContent,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
      };
      final lesson = await remoteDataSource.createLesson(data);
      return Right(lesson);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnrollmentEntity>> enrollCourse({
    required int userId,
    required int courseId,
  }) async {
    try {
      final enrollment = await remoteDataSource.enrollCourse(userId, courseId);
      return Right(enrollment);
    } on AlreadyEnrolledException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EnrollmentEntity>>> getMyEnrollments(
    int userId,
  ) async {
    try {
      final enrollments = await remoteDataSource.getMyEnrollments(userId);
      return Right(enrollments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EnrollmentEntity>> getEnrollment({
    required int userId,
    required int courseId,
  }) async {
    try {
      final enrollments = await remoteDataSource.getMyEnrollments(userId);
      final enrollment = enrollments.firstWhere((e) => e.courseId == courseId);
      return Right(enrollment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLessonProgress({
    required int userId,
    required int lessonId,
    int lastWatchedPosition = 0,
    bool isCompleted = false,
  }) async {
    try {
      await remoteDataSource.updateLessonProgress(
        userId: userId,
        lessonId: lessonId,
        lastWatchedPosition: lastWatchedPosition,
        isCompleted: isCompleted,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LessonProgressEntity?>> getLessonProgress({
    required int userId,
    required int lessonId,
  }) async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(int lessonId) async {
    try {
      final comments = await remoteDataSource.getComments(lessonId);
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createComment({
    required int lessonId,
    required int userId,
    required String content,
    int? parentId,
  }) async {
    try {
      final data = {
        'lessonId': lessonId,
        'userId': userId,
        'content': content,
        if (parentId != null) 'parentId': parentId,
      };
      await remoteDataSource.createComment(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSubmission({
    required int assignmentId,
    required int studentId,
    String? textContent,
    String? linkUrl,
  }) async {
    try {
      final data = {
        'assignmentId': assignmentId,
        'studentId': studentId,
        if (textContent != null) 'textContent': textContent,
        if (linkUrl != null) 'linkUrl': linkUrl,
      };
      await remoteDataSource.createSubmission(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubmissionEntity>>> getSubmissions(
    int assignmentId,
  ) async {
    try {
      final submissions = await remoteDataSource.getSubmissions(assignmentId);
      return Right(submissions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseStudentEntity>>> getCourseStudents(
    int courseId,
  ) async {
    try {
      final students = await remoteDataSource.getCourseStudents(courseId);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final updates = <String, dynamic>{
        if (title != null) 'title': title,
        if (type != null) 'type': type,
        if (contentUrl != null) 'contentUrl': contentUrl,
        if (textContent != null) 'textContent': textContent,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (isFreePreview != null) 'isFreePreview': isFreePreview,
        if (orderIndex != null) 'orderIndex': orderIndex,
      };
      await remoteDataSource.updateLesson(lessonId, updates);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLesson({
    required int courseId,
    required int moduleId,
    required int lessonId,
  }) async {
    try {
      await remoteDataSource.deleteLesson(lessonId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
