import 'package:get_it/get_it.dart';
import '../features/teaching/data/datasources/student_remote_data_source.dart';
import '../features/teaching/data/repositories/student_repository_impl.dart';
import '../features/teaching/domain/repositories/student_repository.dart';
import '../features/teaching/domain/usecases/submit_assignment_usecase.dart';
import '../features/teaching/domain/usecases/get_student_assignments_usecase.dart';
import '../features/teaching/presentation/bloc/student_bloc.dart';

void initStudentModule(GetIt sl) {
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SubmitAssignmentUseCase(sl()));
  sl.registerLazySingleton(() => GetStudentAssignmentsUseCase(sl()));
  sl.registerFactory(
    () => StudentBloc(submitAssignment: sl(), getStudentAssignments: sl()),
  );
}
