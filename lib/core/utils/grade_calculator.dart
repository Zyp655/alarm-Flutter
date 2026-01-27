class GradeCalculator {
  static double? calculateOverallScore({
    required int credits,
    required double? midtermScore,
    required double? finalScore,
    required double? examScore,
    required int currentAbsences,
    required int maxAbsences,
  }) {
    if (examScore == null) return null;

    double attendanceComponent = 10.0;
    if (maxAbsences > 0) {
      attendanceComponent = 10.0 * (1.0 - (currentAbsences / maxAbsences));
      if (attendanceComponent < 0) attendanceComponent = 0;
    }

    double totalScore;

    if (credits >= 3) {
      double mid = midtermScore ?? 0.0;
      double fin = finalScore ?? 0.0;

      totalScore =
          (attendanceComponent * 0.1) +
          (mid * 0.15) +
          (fin * 0.15) +
          (examScore * 0.6);
    } else {
      double fin = finalScore ?? 0.0;

      totalScore =
          (attendanceComponent * 0.1) + (fin * 0.3) + (examScore * 0.6);
    }

    return double.parse(totalScore.toStringAsFixed(1));
  }
}
