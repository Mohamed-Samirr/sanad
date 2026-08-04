import '../../../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';
import '../entities/habit_stats.dart';
import '../entities/health_score_config.dart';

/// Pure domain logic. No Flutter, no Hive, fully unit-testable.
///
/// The curve is always rebuilt from the first day of the habit, never stored
/// incrementally — so back-filling or removing an old day corrects the whole
/// history instead of only the tail.
class HealthScoreCalculator {
  final HealthScoreConfig config;

  const HealthScoreCalculator({this.config = const HealthScoreConfig()});

  List<HealthPoint> buildCurve({
    required Habit habit,
    required Map<String, HabitLog> logsByDay,
    required DateTime today,
  }) {
    final points = <HealthPoint>[];
    var score = config.initialScore;
    var consecutiveMisses = 0;
    var streak = 0;

    var cursor = AppDateUtils.startOfDay(habit.startDate);
    final end = AppDateUtils.startOfDay(today);
    if (cursor.isAfter(end)) return points;

    var weekStart = AppDateUtils.startOfWeek(cursor);
    var weekCompletions = 0;

    while (!cursor.isAfter(end)) {
      final cursorWeekStart = AppDateUtils.startOfWeek(cursor);
      if (cursorWeekStart != weekStart) {
        weekStart = cursorWeekStart;
        weekCompletions = 0;
      }

      final log = logsByDay[AppDateUtils.dayKey(cursor)];
      final isDone = log?.status == HabitLogStatus.done;
      final isSkipped = log?.status == HabitLogStatus.skipped;

      var costsOnMiss = habit.isScheduledOn(cursor);
      if (habit.scheduleType == HabitScheduleType.timesPerWeek) {
        costsOnMiss = _isCriticalDay(habit, cursor, weekCompletions);
      }

      if (isDone) {
        streak += 1;
        consecutiveMisses = 0;
        weekCompletions += 1;
        final bonus =
            (streak * config.streakBonusPerDay).clamp(0.0, config.maxStreakBonus);
        score += config.gainPerHit + bonus;
      } else if (isSkipped || !costsOnMiss) {
        // Neutral day: no decay, no gain, streak survives a deliberate skip.
      } else {
        consecutiveMisses += 1;
        streak = 0;
        final multiplier =
            (1 + config.decayCompoundStep * (consecutiveMisses - 1))
                .clamp(1.0, config.maxDecayMultiplier);
        score -= config.decayPerMiss * multiplier;
      }

      score = score.clamp(0.0, 100.0);
      points.add(HealthPoint(date: cursor, score: score, completed: isDone));
      cursor = AppDateUtils.addDays(cursor, 1);
    }

    return points;
  }

  HabitStats buildStats({
    required Habit habit,
    required List<HabitLog> logs,
    required DateTime today,
    int trendWindowDays = 30,
  }) {
    final logsByDay = <String, HabitLog>{
      for (final log in logs) AppDateUtils.dayKey(log.date): log,
    };

    final curve = buildCurve(habit: habit, logsByDay: logsByDay, today: today);
    final trend = curve.length <= trendWindowDays
        ? curve
        : curve.sublist(curve.length - trendWindowDays);

    final currentScore = curve.isEmpty ? config.initialScore : curve.last.score;

    var completedDays = 0;
    var scheduledDays = 0;
    var currentStreak = 0;
    var bestStreak = 0;

    for (final point in curve) {
      final log = logsByDay[AppDateUtils.dayKey(point.date)];
      final isSkipped = log?.status == HabitLogStatus.skipped;
      final scheduled = habit.isScheduledOn(point.date) && !isSkipped;

      if (scheduled) scheduledDays += 1;
      if (point.completed) {
        completedDays += 1;
        currentStreak += 1;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else if (scheduled) {
        currentStreak = 0;
      }
    }

    // Today has not happened yet — an open day should not break the streak.
    if (curve.isNotEmpty && !curve.last.completed) {
      final yesterdayStreak = _streakEndingAt(curve, curve.length - 2);
      currentStreak = currentStreak == 0 ? yesterdayStreak : currentStreak;
    }

    return HabitStats(
      currentScore: currentScore,
      deltaVsLastWeek: currentScore - _lastWeekAverage(curve, today),
      completedDays: completedDays,
      scheduledDays: scheduledDays,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      trend: trend,
      loggedDays: logs.length,
      riskThreshold: config.riskThreshold,
      minimumDataPoints: config.minimumDataPoints,
    );
  }

  /// A `timesPerWeek` day only costs points when the quota can no longer be
  /// met by the days that are left in the week.
  bool _isCriticalDay(Habit habit, DateTime day, int weekCompletions) {
    final quota = habit.timesPerWeek ?? 0;
    final stillRequired = quota - weekCompletions;
    if (stillRequired <= 0) return false;

    final weekStart = AppDateUtils.startOfWeek(day);
    final dayIndex = AppDateUtils.daysBetween(weekStart, day); // 0..6
    final remainingDays = 7 - dayIndex;
    return stillRequired >= remainingDays;
  }

  double _lastWeekAverage(List<HealthPoint> curve, DateTime today) {
    if (curve.isEmpty) return config.initialScore;
    final end = AppDateUtils.addDays(today, -7);
    final start = AppDateUtils.addDays(today, -14);
    final window = curve
        .where((p) => !p.date.isBefore(start) && p.date.isBefore(end))
        .toList();
    if (window.isEmpty) return curve.first.score;
    final sum = window.fold<double>(0, (acc, p) => acc + p.score);
    return sum / window.length;
  }

  int _streakEndingAt(List<HealthPoint> curve, int index) {
    var streak = 0;
    for (var i = index; i >= 0; i--) {
      if (curve[i].completed) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }
}
