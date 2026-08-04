class HealthPoint {
  final DateTime date;
  final double score;
  final bool completed;

  const HealthPoint({
    required this.date,
    required this.score,
    required this.completed,
  });
}

class HabitStats {
  final double currentScore;

  /// Current score minus last week's average score.
  final double deltaVsLastWeek;

  final int completedDays;
  final int scheduledDays;
  final int currentStreak;
  final int bestStreak;

  /// Score curve for the trend chart (already trimmed to the window).
  final List<HealthPoint> trend;

  /// Number of days the user has actually logged — drives the empty state.
  final int loggedDays;

  final double riskThreshold;
  final int minimumDataPoints;

  const HabitStats({
    required this.currentScore,
    required this.deltaVsLastWeek,
    required this.completedDays,
    required this.scheduledDays,
    required this.currentStreak,
    required this.bestStreak,
    required this.trend,
    required this.loggedDays,
    required this.riskThreshold,
    required this.minimumDataPoints,
  });

  double get completionRate =>
      scheduledDays == 0 ? 0 : completedDays / scheduledDays;

  int get completionPercent => (completionRate * 100).round();

  bool get hasEnoughData => loggedDays >= minimumDataPoints;

  bool get isAtRisk => currentScore < riskThreshold;
}
