import 'package:equatable/equatable.dart';

class VelocityData extends Equatable {
  final int totalLessons;
  final int completedLessons;
  final int remainingLessons;
  final double? dailyVelocity;
  final DateTime? predictedCompletionDate;
  final String trend;
  final double confidence;
  final List<DailyProgress> dailyProgress;

  const VelocityData({
    required this.totalLessons,
    required this.completedLessons,
    required this.remainingLessons,
    this.dailyVelocity,
    this.predictedCompletionDate,
    required this.trend,
    required this.confidence,
    required this.dailyProgress,
  });

  double get progressPercent =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;

  @override
  List<Object?> get props => [
    totalLessons,
    completedLessons,
    remainingLessons,
    dailyVelocity,
    predictedCompletionDate,
    trend,
    confidence,
    dailyProgress,
  ];
}

class DailyProgress extends Equatable {
  final DateTime date;
  final int lessonsCompleted;

  const DailyProgress({required this.date, required this.lessonsCompleted});

  @override
  List<Object?> get props => [date, lessonsCompleted];
}
