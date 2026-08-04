/// Every tunable number in the health score lives here.
class HealthScoreConfig {
  final double initialScore;
  final double decayPerMiss;
  final double decayCompoundStep;
  final double maxDecayMultiplier;
  final double gainPerHit;
  final double streakBonusPerDay;
  final double maxStreakBonus;

  /// Below this the habit is treated as at risk.
  final double riskThreshold;

  /// Days of history needed before the trend card shows a chart.
  final int minimumDataPoints;

  const HealthScoreConfig({
    this.initialScore = 75,
    this.decayPerMiss = 4,
    this.decayCompoundStep = 0.15,
    this.maxDecayMultiplier = 3,
    this.gainPerHit = 8,
    this.streakBonusPerDay = 1,
    this.maxStreakBonus = 5,
    this.riskThreshold = 50,
    this.minimumDataPoints = 5,
  });
}
