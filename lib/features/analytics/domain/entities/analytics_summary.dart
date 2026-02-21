import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int weekStudyMinutes;
  final int activeCourses;
  final double overallProgress;
  final int completedLessons;
  final int todayActivities;

  const AnalyticsSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.weekStudyMinutes,
    required this.activeCourses,
    required this.overallProgress,
    required this.completedLessons,
    required this.todayActivities,
  });

  String get weekStudyTimeFormatted {
    final hours = weekStudyMinutes ~/ 60;
    final mins = weekStudyMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    weekStudyMinutes,
    activeCourses,
    overallProgress,
    completedLessons,
    todayActivities,
  ];
}
