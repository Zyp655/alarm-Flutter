import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/common/theme_cubit.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/login_usercase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'features/schedule/data/repositories/schedule_repository_impl.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/domain/usecases/add_schedule_usecase.dart';
import 'features/schedule/domain/usecases/get_schedules_usecase.dart';

// 👇 Đừng quên Import 2 file này
import 'features/schedule/domain/usecases/delete_schedule_usecase.dart';
import 'features/schedule/domain/usecases/join_class_usecase.dart';
import 'features/schedule/domain/usecases/update_schedule_usecase.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/teaching/data/datasources/teacher_remote_data_source.dart';
import 'features/teaching/data/repositories/teacher_repository_impl.dart';
import 'features/teaching/domain/repositories/teacher_repository.dart';
import 'features/teaching/domain/usecases/create_class_usecase.dart';
import 'features/teaching/domain/usecases/create_subject_usecase.dart';
import 'features/teaching/domain/usecases/get_subject_usecase.dart';
import 'features/teaching/domain/usecases/get_teacher_schedules_usecase.dart';
import 'features/teaching/domain/usecases/import_schedules_usecase.dart';
import 'features/teaching/domain/usecases/regenerate_class_code_usecase.dart';
import 'features/teaching/domain/usecases/update_student_score_usecase.dart';
import 'features/teaching/domain/usecases/get_students_in_class_usecase.dart';
import 'features/teaching/domain/usecases/get_assignments_usecase.dart';
import 'features/teaching/domain/usecases/create_assignment_usecase.dart';
import 'features/teaching/presentation/bloc/teacher_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- AUTH FEATURE ---
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      forgotPasswordUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => TeacherBloc(
      getTeacherSchedules: sl(),
      createClass: sl(),
      updateScore: sl(),
      importSchedules: sl(),
      regenerateClassCode: sl(),
      getStudentsInClass: sl(),
      getSubjects: sl(),
      createSubject: sl(),
      getAssignments: sl(),
      createAssignment: sl(),
      updateSchedule: sl(),
      deleteSchedule: sl(),
    ),
  );
  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TeacherRemoteDataSource>(
    () => TeacherRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetTeacherSchedulesUseCase(sl()));
  sl.registerLazySingleton(() => CreateClassUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStudentScoreUseCase(sl()));
  sl.registerLazySingleton(() => ImportSchedulesUseCase(sl()));
  sl.registerLazySingleton(() => RegenerateClassCodeUseCase(sl()));
  sl.registerLazySingleton(() => GetSubjectsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubjectUseCase(sl()));

  sl.registerLazySingleton(() => GetStudentsInClassUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignmentsUseCase(sl()));
  sl.registerLazySingleton(() => CreateAssignmentUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerFactory(
    () => ScheduleBloc(
      getSchedulesUseCase: sl(),
      addScheduleUseCase: sl(),
      deleteScheduleUseCase: sl(),
      updateScheduleUseCase: sl(),
      joinClassUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetSchedulesUseCase(sl()));
  sl.registerLazySingleton(() => AddScheduleUseCase(sl()));

  sl.registerLazySingleton(() => JoinClassUseCase(sl()));
  sl.registerLazySingleton(() => DeleteScheduleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateScheduleUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(sl()),
  );

  sl.registerFactory(() => ThemeCubit());
  sl.registerLazySingleton(() => ApiClient(client: sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}
