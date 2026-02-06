import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/submission_entity.dart';
import '../../domain/repositories/course_repository.dart';

abstract class SubmissionEvent {}

class CreateSubmissionEvent extends SubmissionEvent {
  final int assignmentId;
  final int studentId;
  final String? textContent;
  final String? linkUrl;
  CreateSubmissionEvent({
    required this.assignmentId,
    required this.studentId,
    this.textContent,
    this.linkUrl,
  });
}

class LoadMySubmissionEvent extends SubmissionEvent {
  final int assignmentId;
  final int studentId;
  LoadMySubmissionEvent({required this.assignmentId, required this.studentId});
}

class LoadAllSubmissionsEvent extends SubmissionEvent {
  final int assignmentId;
  LoadAllSubmissionsEvent(this.assignmentId);
}

abstract class SubmissionState {}

class SubmissionInitial extends SubmissionState {}

class SubmissionLoading extends SubmissionState {}

class SubmissionSuccess extends SubmissionState {
  final String message;
  SubmissionSuccess(this.message);
}

class MySubmissionLoaded extends SubmissionState {
  final SubmissionEntity submission;
  MySubmissionLoaded(this.submission);
}

class AllSubmissionsLoaded extends SubmissionState {
  final List<SubmissionEntity> submissions;
  AllSubmissionsLoaded(this.submissions);
}

class SubmissionEmpty extends SubmissionState {}

class SubmissionError extends SubmissionState {
  final String message;
  SubmissionError(this.message);
}

class SubmissionBloc extends Bloc<SubmissionEvent, SubmissionState> {
  final CourseRepository repository;

  SubmissionBloc({required this.repository}) : super(SubmissionInitial()) {
    on<CreateSubmissionEvent>(_onCreateSubmission);
    on<LoadMySubmissionEvent>(_onLoadMySubmission);
    on<LoadAllSubmissionsEvent>(_onLoadAllSubmissions);
  }

  Future<void> _onCreateSubmission(
    CreateSubmissionEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await repository.createSubmission(
      assignmentId: event.assignmentId,
      studentId: event.studentId,
      textContent: event.textContent,
      linkUrl: event.linkUrl,
    );
    result.fold(
      (failure) => emit(SubmissionError(failure.message)),
      (_) => emit(SubmissionSuccess('Nộp bài thành công!')),
    );
  }

  Future<void> _onLoadMySubmission(
    LoadMySubmissionEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await repository.getSubmissions(event.assignmentId);

    result.fold((failure) => emit(SubmissionError(failure.message)), (
      submissions,
    ) {
      final mySub = submissions
          .where((s) => s.studentId == event.studentId)
          .firstOrNull;
      if (mySub != null) {
        emit(MySubmissionLoaded(mySub));
      } else {
        emit(SubmissionEmpty());
      }
    });
  }

  Future<void> _onLoadAllSubmissions(
    LoadAllSubmissionsEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await repository.getSubmissions(event.assignmentId);
    result.fold(
      (failure) => emit(SubmissionError(failure.message)),
      (submissions) => emit(AllSubmissionsLoaded(submissions)),
    );
  }
}
