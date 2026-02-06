import 'package:equatable/equatable.dart';

abstract class MyCoursesEvent extends Equatable {
  const MyCoursesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyCoursesEvent extends MyCoursesEvent {
  final int userId;

  const LoadMyCoursesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshMyCoursesEvent extends MyCoursesEvent {
  final int userId;

  const RefreshMyCoursesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
