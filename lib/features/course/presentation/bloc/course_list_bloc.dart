import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_courses_usecase.dart';
import '../../domain/usecases/create_course_usecase.dart';
import '../../domain/usecases/delete_course_usecase.dart';
import 'course_list_event.dart';
import 'course_list_state.dart';

class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  final GetCoursesUseCase getCoursesUseCase;
  final CreateCourseUseCase createCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  CourseListBloc({
    required this.getCoursesUseCase,
    required this.createCourseUseCase,
    required this.deleteCourseUseCase,
  }) : super(CourseListInitial()) {
    on<LoadCoursesEvent>(_onLoadCourses);
    on<RefreshCoursesEvent>(_onRefreshCourses);
    on<CreateCourseEvent>(_onCreateCourse);
    on<DeleteCourseEvent>(_onDeleteCourse);
  }

  LoadCoursesEvent? _lastLoadEvent;

  Future<void> _onLoadCourses(
    LoadCoursesEvent event,
    Emitter<CourseListState> emit,
  ) async {
    _lastLoadEvent = event;
    emit(CourseListLoading());

    final result = await getCoursesUseCase(
      search: event.search,
      level: event.level,
      instructorId: event.instructorId,
      majorId: event.majorId,
      showUnpublished: event.showUnpublished,
    );

    result.fold(
      (failure) => emit(CourseListError(failure.message)),
      (courses) => emit(CourseListLoaded(courses)),
    );
  }

  Future<void> _onRefreshCourses(
    RefreshCoursesEvent event,
    Emitter<CourseListState> emit,
  ) async {
    final result = await getCoursesUseCase(
      search: _lastLoadEvent?.search,
      level: _lastLoadEvent?.level,
      instructorId: _lastLoadEvent?.instructorId,
      majorId: _lastLoadEvent?.majorId,
      showUnpublished: _lastLoadEvent?.showUnpublished ?? false,
    );

    result.fold(
      (failure) => emit(CourseListError(failure.message)),
      (courses) => emit(CourseListLoaded(courses)),
    );
  }

  Future<void> _onCreateCourse(
    CreateCourseEvent event,
    Emitter<CourseListState> emit,
  ) async {
    final result = await createCourseUseCase(
      title: event.title,
      description: event.description,
      level: event.level,
      instructorId: event.instructorId,
    );

    result.fold(
      (failure) =>
          emit(CourseListError(failure.message)), 
      (course) => add(RefreshCoursesEvent()), 
    );
  }

  Future<void> _onDeleteCourse(
    DeleteCourseEvent event,
    Emitter<CourseListState> emit,
  ) async {
    final result = await deleteCourseUseCase(event.courseId);

    result.fold(
      (failure) => emit(CourseListError(failure.message)),
      (_) => add(RefreshCoursesEvent()),
    );
  }
}
