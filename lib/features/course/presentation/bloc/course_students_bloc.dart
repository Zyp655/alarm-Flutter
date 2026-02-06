import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_student_entity.dart';
import '../../domain/repositories/course_repository.dart';

abstract class CourseStudentsEvent {}

class LoadCourseStudentsEvent extends CourseStudentsEvent {
  final int courseId;
  LoadCourseStudentsEvent(this.courseId);
}

abstract class CourseStudentsState {}

class CourseStudentsInitial extends CourseStudentsState {}

class CourseStudentsLoading extends CourseStudentsState {}

class CourseStudentsLoaded extends CourseStudentsState {
  final List<CourseStudentEntity> students;
  CourseStudentsLoaded(this.students);
}

class CourseStudentsError extends CourseStudentsState {
  final String message;
  CourseStudentsError(this.message);
}

class CourseStudentsBloc
    extends Bloc<CourseStudentsEvent, CourseStudentsState> {
  final CourseRepository repository;

  CourseStudentsBloc({required this.repository})
    : super(CourseStudentsInitial()) {
    on<LoadCourseStudentsEvent>(_onLoadStudents);
  }

  Future<void> _onLoadStudents(
    LoadCourseStudentsEvent event,
    Emitter<CourseStudentsState> emit,
  ) async {
    emit(CourseStudentsLoading());
    final result = await repository.getCourseStudents(event.courseId);
    result.fold(
      (failure) => emit(CourseStudentsError(failure.message)),
      (students) => emit(CourseStudentsLoaded(students)),
    );
  }
}
