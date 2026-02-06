import 'package:equatable/equatable.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/entities/module_entity.dart';

abstract class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

class CourseDetailInitial extends CourseDetailState {}

class CourseDetailLoading extends CourseDetailState {}

class CourseDetailLoaded extends CourseDetailState {
  final CourseEntity course;
  final List<ModuleEntity> modules;
  final EnrollmentEntity? enrollment; 
  final String? actionError;
  final bool isJustEnrolled;

  const CourseDetailLoaded({
    required this.course,
    required this.modules,
    this.enrollment,
    this.actionError,
    this.isJustEnrolled = false,
  });

  @override
  List<Object?> get props => [
    course,
    modules,
    enrollment,
    actionError,
    isJustEnrolled,
  ];

  CourseDetailLoaded copyWith({
    CourseEntity? course,
    List<ModuleEntity>? modules,
    EnrollmentEntity? enrollment,
    String? actionError,
    bool? isJustEnrolled,
  }) {
    return CourseDetailLoaded(
      course: course ?? this.course,
      modules: modules ?? this.modules,
      enrollment: enrollment ?? this.enrollment,
      actionError: actionError,
      isJustEnrolled: isJustEnrolled ?? false,
    );
  }
}

class CourseDetailError extends CourseDetailState {
  final String message;

  const CourseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class CourseEnrollmentSuccess extends CourseDetailState {
  final EnrollmentEntity enrollment;

  const CourseEnrollmentSuccess(this.enrollment);

  @override
  List<Object?> get props => [enrollment];
}
