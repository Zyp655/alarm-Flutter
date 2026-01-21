import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_class_usecase.dart';
import '../../domain/usecases/create_subject_usecase.dart';
import '../../domain/usecases/get_subject_usecase.dart';
import '../../domain/usecases/get_teacher_schedules_usecase.dart';
import '../../domain/usecases/import_schedules_usecase.dart';
import '../../domain/usecases/regenerate_class_code_usecase.dart';
import '../../domain/usecases/update_student_score_usecase.dart';
import '../../domain/usecases/get_students_in_class_usecase.dart';
import '../../domain/usecases/get_assignments_usecase.dart';
import '../../domain/usecases/create_assignment_usecase.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final GetTeacherSchedulesUseCase getTeacherSchedules;
  final CreateClassUseCase createClass;
  final UpdateStudentScoreUseCase updateScore;
  final ImportSchedulesUseCase importSchedules;
  final RegenerateClassCodeUseCase regenerateClassCode;
  final GetStudentsInClassUseCase getStudentsInClass;
  final GetAssignmentsUseCase getAssignments;
  final CreateAssignmentUseCase createAssignment;

  final GetSubjectsUseCase getSubjects;
  final CreateSubjectUseCase createSubject;

  TeacherBloc({
    required this.getTeacherSchedules,
    required this.createClass,
    required this.updateScore,
    required this.importSchedules,
    required this.regenerateClassCode,
    required this.getStudentsInClass,
    required this.getSubjects,
    required this.createSubject,
    required this.getAssignments,
    required this.createAssignment,
  }) : super(TeacherInitial()) {
    on<LoadSubjects>((event, emit) async {
      emit(TeacherLoading());
      final result = await getSubjects(event.teacherId);
      result.fold(
        (failure) => emit(TeacherError(failure.message)),
        (subjects) => emit(SubjectsLoaded(subjects)),
      );
    });

    on<CreateSubjectRequested>((event, emit) async {
      emit(TeacherLoading());
      final result = await createSubject(
        event.teacherId,
        event.name,
        event.credits,
        event.code,
      );
      result.fold((failure) => emit(TeacherError(failure.message)), (_) {
        emit(SubjectCreatedSuccess());
        add(LoadSubjects(event.teacherId));
      });
    });

    on<LoadTeacherClasses>((event, emit) async {
      emit(TeacherLoading());
      final result = await getTeacherSchedules(event.teacherId);
      result.fold(
        (failure) => emit(TeacherError(failure.message)),
        (schedules) => emit(TeacherLoaded(schedules)),
      );
    });

    on<CreateClassRequested>((event, emit) async {
      final result = await createClass(
        event.className,
        event.teacherId,
        event.subjectName,
        event.room,
        event.startTime,
        event.endTime,
        event.startDate,
        event.repeatWeeks,
        event.notificationMinutes,
        event.credits,
      );
      result.fold((failure) => emit(TeacherError(failure.message)), (_) {
        emit(ClassCreatedSuccess());
        add(LoadTeacherClasses(event.teacherId));
      });
    });

    on<UpdateScoreRequested>((event, emit) async {
      emit(TeacherLoading());
      final result = await updateScore(
        event.scheduleId,
        event.absences,
        event.midtermScore,
        event.finalScore,
      );
      result.fold((failure) => emit(TeacherError(failure.message)), (_) {
        emit(ScoreUpdatedSuccess());
        add(LoadTeacherClasses(event.teacherId));
      });
    });

    on<ImportSchedulesRequested>((event, emit) async {
      emit(TeacherLoading());
      final result = await importSchedules(event.teacherId, event.schedules);
      result.fold((failure) => emit(TeacherError(failure.message)), (_) {
        emit(ImportSuccess());
        add(LoadTeacherClasses(event.teacherId));
      });
    });

    on<GetStudentsInClass>((event, emit) async {
      emit(TeacherLoading());
      final result = await getStudentsInClass(event.classId);
      result.fold(
        (failure) => emit(TeacherError(failure.message)),
        (students) => emit(StudentsLoaded(students)),
      );
    });

    on<RegenerateCodeRequested>(_onRegenerateCode);

    on<LoadAssignments>((event, emit) async {
      emit(TeacherLoading());
      final result = await getAssignments(event.teacherId);
      result.fold(
        (failure) => emit(TeacherError(failure.message)),
        (assignments) => emit(AssignmentsLoaded(assignments)),
      );
    });

    on<CreateAssignmentRequested>((event, emit) async {
      emit(TeacherLoading());
      final result = await createAssignment(event.assignment, event.teacherId);
      result.fold((failure) => emit(TeacherError(failure.message)), (_) {
        emit(AssignmentCreatedSuccess());
        add(LoadAssignments(event.teacherId));
      });
    });
  }

  Future<void> _onRegenerateCode(
    RegenerateCodeRequested event,
    Emitter<TeacherState> emit,
  ) async {
    final result = await regenerateClassCode(
      event.teacherId,
      event.subjectName,
      event.isRefresh,
    );
    result.fold((failure) => emit(TeacherError(failure.message)), (newCode) {
      emit(CodeRegeneratedSuccess(newCode, "Đã cập nhật mã lớp mới!"));
      add(LoadTeacherClasses(event.teacherId));
    });
  }
}
