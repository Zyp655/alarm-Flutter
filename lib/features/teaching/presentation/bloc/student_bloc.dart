import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_assignment_usecase.dart';
import '../../domain/usecases/get_student_assignments_usecase.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final SubmitAssignmentUseCase submitAssignment;
  final GetStudentAssignmentsUseCase getStudentAssignments;

  StudentBloc({
    required this.submitAssignment,
    required this.getStudentAssignments,
  }) : super(StudentInitial()) {
    on<SubmitAssignmentEvent>(_onSubmitAssignment);
    on<GetStudentAssignmentsEvent>(_onGetStudentAssignments);
  }

  Future<void> _onSubmitAssignment(
    SubmitAssignmentEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final result = await submitAssignment(
      assignmentId: event.assignmentId,
      studentId: event.studentId,
      file: event.file,
      link: event.link,
      text: event.text,
    );

    result.fold(
      (failure) => emit(StudentError(failure.message)),
      (_) => emit(const SubmissionSuccess('Nộp bài thành công!')),
    );
  }

  Future<void> _onGetStudentAssignments(
    GetStudentAssignmentsEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());
    final result = await getStudentAssignments(event.studentId);
    result.fold(
      (failure) => emit(StudentError(failure.message)),
      (assignments) => emit(StudentAssignmentsLoaded(assignments)),
    );
  }
}
