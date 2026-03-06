import 'package:get_it/get_it.dart';
import '../features/course/data/datasources/course_remote_datasource.dart';
import '../features/course/data/repositories/course_repository_impl.dart';
import '../features/course/domain/repositories/course_repository.dart';
import '../features/course/domain/usecases/get_courses_usecase.dart';
import '../features/course/domain/usecases/create_course_usecase.dart';
import '../features/course/domain/usecases/delete_course_usecase.dart';
import '../features/course/domain/usecases/get_course_details_usecase.dart';
import '../features/course/domain/usecases/get_course_curriculum_usecase.dart';
import '../features/course/domain/usecases/enroll_course_usecase.dart';
import '../features/course/domain/usecases/get_my_courses_usecase.dart';
import '../features/course/domain/usecases/create_module_usecase.dart';
import '../features/course/domain/usecases/create_lesson_usecase.dart';
import '../features/course/domain/usecases/update_lesson_usecase.dart';
import '../features/course/domain/usecases/delete_lesson_usecase.dart';
import '../features/course/domain/usecases/update_lesson_progress_usecase.dart';
import '../features/course/presentation/bloc/course_list_bloc.dart';
import '../features/course/presentation/bloc/course_detail_bloc.dart';
import '../features/course/presentation/bloc/my_courses_bloc.dart';
import '../features/course/presentation/bloc/learning_player_bloc.dart';
import '../features/course/presentation/bloc/submission_bloc.dart';
import '../features/course/presentation/bloc/course_students_bloc.dart';

void initCourseModule(GetIt sl) {
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetCoursesUseCase(sl()));
  sl.registerLazySingleton(() => CreateCourseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCourseUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseCurriculumUseCase(sl()));
  sl.registerLazySingleton(() => EnrollCourseUseCase(sl()));
  sl.registerLazySingleton(() => GetMyCoursesUseCase(sl()));
  sl.registerLazySingleton(() => CreateModuleUseCase(sl()));
  sl.registerLazySingleton(() => CreateLessonUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLessonUseCase(sl()));
  sl.registerLazySingleton(() => DeleteLessonUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLessonProgressUseCase(sl()));

  sl.registerFactory(
    () => CourseListBloc(
      getCoursesUseCase: sl(),
      createCourseUseCase: sl(),
      deleteCourseUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CourseDetailBloc(
      getCourseDetailsUseCase: sl(),
      getCourseCurriculumUseCase: sl(),
      enrollCourseUseCase: sl(),
      getMyCoursesUseCase: sl(),
      createModuleUseCase: sl(),
      createLessonUseCase: sl(),
      updateLessonUseCase: sl(),
      deleteLessonUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => MyCoursesBloc(getMyCoursesUseCase: sl(), courseRepository: sl()),
  );
  sl.registerFactory(
    () => LearningPlayerBloc(updateLessonProgressUseCase: sl()),
  );
  sl.registerFactory(() => SubmissionBloc(repository: sl()));
  sl.registerFactory(() => CourseStudentsBloc(repository: sl()));
}
