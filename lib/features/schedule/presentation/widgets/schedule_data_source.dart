import 'package:flutter/material.dart';
import '../../domain/enitities/schedule_entity.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<ScheduleEntity> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as ScheduleEntity).start;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as ScheduleEntity).end;
  }

  @override
  String getSubject(int index) {
    final item = appointments![index] as ScheduleEntity;
    return "${item.subject}\nPhòng: ${item.room}";
  }

  @override
  Color getColor(int index) {
    final item = appointments![index] as ScheduleEntity;

    if (item.currentAbsences >= item.maxAbsences) {
      return Colors.red;
    }

    return Colors.primaries[item.subject.hashCode % Colors.primaries.length];
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}