import 'package:equatable/equatable.dart';
import '../../domain/entities/course_entity.dart';

abstract class CourseListState extends Equatable {
  const CourseListState();

  @override
  List<Object?> get props => [];
}

class CourseListInitial extends CourseListState {}

class CourseListLoading extends CourseListState {}

class CourseListLoaded extends CourseListState {
  final List<CourseEntity> courses;

  const CourseListLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseListError extends CourseListState {
  final String message;

  const CourseListError(this.message);

  @override
  List<Object?> get props => [message];
}
