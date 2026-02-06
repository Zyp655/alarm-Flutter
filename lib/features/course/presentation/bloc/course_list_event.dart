import 'package:equatable/equatable.dart';

abstract class CourseListEvent extends Equatable {
  const CourseListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCoursesEvent extends CourseListEvent {
  final String? search;
  final String? level;
  final int? instructorId;
  final int? majorId;
  final bool showUnpublished;

  const LoadCoursesEvent({
    this.search,
    this.level,
    this.instructorId,
    this.majorId,
    this.showUnpublished = false,
  });

  @override
  List<Object?> get props => [
    search,
    level,
    instructorId,
    majorId,
    showUnpublished,
  ];
}

class RefreshCoursesEvent extends CourseListEvent {}

class CreateCourseEvent extends CourseListEvent {
  final String title;
  final String description;
  final String level;
  final int instructorId;

  const CreateCourseEvent({
    required this.title,
    required this.description,
    required this.level,
    required this.instructorId,
  });

  @override
  List<Object?> get props => [title, description, level, instructorId];
}

class DeleteCourseEvent extends CourseListEvent {
  final int courseId;

  const DeleteCourseEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}
