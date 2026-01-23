import 'package:equatable/equatable.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/assignment_entity.dart';

abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object> get props => [];
}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final List<ScheduleEntity> schedules;

  const TeacherLoaded(this.schedules);

  @override
  List<Object> get props => [schedules];
}

class TeacherError extends TeacherState {
  final String message;

  const TeacherError(this.message);

  @override
  List<Object> get props => [message];
}

class ClassCreatedSuccess extends TeacherState {}

class ScoreUpdatedSuccess extends TeacherState {}

class ImportSuccess extends TeacherState {}

class SubjectsLoaded extends TeacherState {
  final List<SubjectEntity> subjects;
  const SubjectsLoaded(this.subjects);
}

class SubjectCreatedSuccess extends TeacherState {}

class CodeRegeneratedSuccess extends TeacherState {
  final String newCode;
  final String message;
  const CodeRegeneratedSuccess(this.newCode, this.message);
  @override
  List<Object> get props => [newCode, message];
}

class StudentsLoaded extends TeacherState {
  final List<StudentEntity> students;
  const StudentsLoaded(this.students);
  @override
  List<Object> get props => [students];
}

class AssignmentsLoaded extends TeacherState {
  final List<AssignmentEntity> assignments;
  const AssignmentsLoaded(this.assignments);
  @override
  List<Object> get props => [assignments];
}

class ClassDeletedSuccess extends TeacherState {}

class ClassUpdatedSuccess extends TeacherState {}

class AssignmentCreatedSuccess extends TeacherState {}

class AssignmentUpdatedSuccess extends TeacherState {}

class AssignmentDeletedSuccess extends TeacherState {}
