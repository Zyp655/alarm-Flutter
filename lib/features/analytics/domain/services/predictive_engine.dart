
class PredictiveEngine {
  
  static PredictionResult predictCompletion({
    required List<DailyProgressPoint> history,
    required int remainingLessons,
    double alpha = 0.3,
  }) {
    if (history.isEmpty || remainingLessons <= 0) {
      return PredictionResult.completed();
    }
    double ema = history.first.lessonsCompleted.toDouble();
    for (int i = 1; i < history.length; i++) {
      ema = alpha * history[i].lessonsCompleted + (1 - alpha) * ema;
    }

    if (ema <= 0.01) return PredictionResult.insufficientData();

    final daysRemaining = (remainingLessons / ema).ceil();
    final trend = _calculateTrend(history);

    return PredictionResult(
      predictedDate: DateTime.now().add(Duration(days: daysRemaining)),
      dailyVelocity: ema,
      trend: trend,
      confidence: _confidence(history.length),
      daysRemaining: daysRemaining,
    );
  }

  static String _calculateTrend(List<DailyProgressPoint> history) {
    if (history.length < 7) return 'insufficient';
    final recent = history.sublist(history.length - 7);
    final older = history.sublist(0, 7.clamp(0, history.length));
    final recentAvg =
        recent.fold<double>(0, (s, e) => s + e.lessonsCompleted) / 7;
    final olderAvg =
        older.fold<double>(0, (s, e) => s + e.lessonsCompleted) / older.length;
    if (recentAvg > olderAvg * 1.1) return 'accelerating';
    if (recentAvg < olderAvg * 0.9) return 'slowing';
    return 'steady';
  }

  static double _confidence(int dataPoints) =>
      (dataPoints / 30.0).clamp(0.0, 1.0);
}

class PredictionResult {
  final DateTime? predictedDate;
  final double dailyVelocity;
  final String trend;
  final double confidence;
  final int daysRemaining;
  final bool isCompleted;
  final bool isInsufficient;

  const PredictionResult({
    this.predictedDate,
    this.dailyVelocity = 0.0,
    this.trend = 'insufficient',
    this.confidence = 0.0,
    this.daysRemaining = 0,
    this.isCompleted = false,
    this.isInsufficient = false,
  });

  factory PredictionResult.completed() => const PredictionResult(
    isCompleted: true,
    trend: 'completed',
    confidence: 1.0,
  );

  factory PredictionResult.insufficientData() => const PredictionResult(
    isInsufficient: true,
    trend: 'insufficient',
    confidence: 0.0,
  );
}

class DailyProgressPoint {
  final DateTime date;
  final int lessonsCompleted;

  const DailyProgressPoint({
    required this.date,
    required this.lessonsCompleted,
  });
}
