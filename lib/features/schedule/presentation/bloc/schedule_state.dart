import '../../domain/enitities/schedule_entity.dart';

abstract class ScheduleState {}
class ScheduleInitial extends ScheduleState {}
class ScheduleLoading extends ScheduleState {}
class ScheduleLoaded extends ScheduleState {
  final List<ScheduleEntity> schedules;
  ScheduleLoaded(this.schedules);
}
class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}
class JoinClassSuccess extends ScheduleState {}