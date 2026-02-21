import 'package:equatable/equatable.dart';

class BenchmarkData extends Equatable {
  final double myProgress;
  final double avgProgress;
  final double topProgress;
  final int totalStudents;
  final int percentileRank;
  final int myStudyMinutes;
  final int avgStudyMinutes;

  const BenchmarkData({
    required this.myProgress,
    required this.avgProgress,
    required this.topProgress,
    required this.totalStudents,
    required this.percentileRank,
    required this.myStudyMinutes,
    required this.avgStudyMinutes,
  });

  
  String get myStudyTimeFormatted => _formatMinutes(myStudyMinutes);
  String get avgStudyTimeFormatted => _formatMinutes(avgStudyMinutes);

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  List<Object?> get props => [
    myProgress,
    avgProgress,
    topProgress,
    totalStudents,
    percentileRank,
    myStudyMinutes,
    avgStudyMinutes,
  ];
}
