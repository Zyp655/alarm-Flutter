import 'package:equatable/equatable.dart';
import '../../domain/entities/student_assignment_entity.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class SubmissionSuccess extends StudentState {
  final String message;
  const SubmissionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);
  @override
  List<Object> get props => [message];
}

class StudentAssignmentsLoaded extends StudentState {
  final List<StudentAssignmentEntity> assignments;

  const StudentAssignmentsLoaded(this.assignments);

  @override
  List<Object> get props => [assignments];
}
