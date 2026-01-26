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
    String prefix = "";
    if (item.type == ScheduleType.exam) prefix = "[THI] ";
    if (item.type == ScheduleType.event) prefix = "[SỰ KIỆN] ";
    return "$prefix${item.subject}\n${item.room.isNotEmpty ? 'Phòng: ${item.room}' : ''}";
  }

  @override
  Color getColor(int index) {
    final item = appointments![index] as ScheduleEntity;

    if (item.type == ScheduleType.exam) {
      return Colors.redAccent;
    }
    if (item.type == ScheduleType.event) {
      return Colors.orange;
    }

    if (item.currentAbsences >= item.maxAbsences) {
      return Colors.red;
    }

    return Colors.blueAccent;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}
