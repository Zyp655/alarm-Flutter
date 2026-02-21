import 'package:equatable/equatable.dart';

class HeatmapEntry extends Equatable {
  final DateTime date;
  final int activityCount;
  final int totalMinutes;

  const HeatmapEntry({
    required this.date,
    required this.activityCount,
    required this.totalMinutes,
  });
  
  int get level {
    if (activityCount == 0) return 0;
    if (activityCount <= 2) return 1;
    if (activityCount <= 5) return 2;
    if (activityCount <= 10) return 3;
    return 4;
  }

  @override
  List<Object?> get props => [date, activityCount, totalMinutes];
}
