import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/utils/date_utils.dart';
import 'package:sanad/features/habits/domain/entities/habit.dart';
import 'package:sanad/features/habits/domain/entities/habit_log.dart';
import 'package:sanad/features/habits/domain/services/health_score_calculator.dart';

void main() {
  const calculator = HealthScoreCalculator();
  final today = AppDateUtils.startOfDay(DateTime(2026, 7, 27));

  Habit buildHabit({
    HabitScheduleType type = HabitScheduleType.daily,
    List<int> weekdays = const [],
    int? timesPerWeek,
    int startedDaysAgo = 24,
  }) {
    return Habit(
      id: 'h1',
      name: 'Working out',
      iconCodePoint: 0xe1a3,
      colorHex: 'FFF2D857',
      timeOfDay: HabitTimeOfDay.evening,
      scheduleType: type,
      scheduledWeekdays: weekdays,
      timesPerWeek: timesPerWeek,
      startDate: AppDateUtils.addDays(today, -startedDaysAgo),
    );
  }

  HabitLog doneOn(DateTime date) => HabitLog(
        habitId: 'h1',
        date: date,
        status: HabitLogStatus.done,
        loggedAt: date,
      );

  test('score decays faster the longer the habit is missed', () {
    final habit = buildHabit();
    final stats = calculator.buildStats(habit: habit, logs: [], today: today);

    expect(stats.currentScore, 0);
    expect(stats.completedDays, 0);
    expect(stats.currentStreak, 0);
    expect(stats.isAtRisk, isTrue);
  });

  test('a completed day lifts the score and starts a streak', () {
    final habit = buildHabit(startedDaysAgo: 3);
    final logs = [
      doneOn(AppDateUtils.addDays(today, -1)),
      doneOn(today),
    ];

    final stats =
        calculator.buildStats(habit: habit, logs: logs, today: today);

    expect(stats.currentStreak, 2);
    expect(stats.bestStreak, 2);
    expect(stats.completedDays, 2);
    expect(stats.currentScore, greaterThan(70));
  });

  test('days outside the weekday schedule are neutral', () {
    final monday = AppDateUtils.startOfWeek(today);
    final habit = Habit(
      id: 'h1',
      name: 'Gym',
      iconCodePoint: 0xe1a3,
      colorHex: 'FFF2D857',
      timeOfDay: HabitTimeOfDay.morning,
      scheduleType: HabitScheduleType.weekdays,
      scheduledWeekdays: const [DateTime.monday],
      startDate: monday,
    );

    final stats = calculator.buildStats(
      habit: habit,
      logs: [doneOn(monday)],
      today: AppDateUtils.addDays(monday, 5),
    );

    expect(stats.scheduledDays, 1);
    expect(stats.completedDays, 1);
    expect(stats.completionPercent, 100);
  });

  test('timesPerWeek only costs points once the quota is at risk', () {
    final monday = AppDateUtils.startOfWeek(today);
    final habit = Habit(
      id: 'h1',
      name: 'Run',
      iconCodePoint: 0xe1a3,
      colorHex: 'FF4ECDC4',
      timeOfDay: HabitTimeOfDay.anytime,
      scheduleType: HabitScheduleType.timesPerWeek,
      timesPerWeek: 2,
      startDate: monday,
    );

    // Tuesday: 5 days still left in the week for a quota of 2 — no decay yet.
    final stats = calculator.buildStats(
      habit: habit,
      logs: const [],
      today: AppDateUtils.addDays(monday, 1),
    );

    expect(stats.currentScore, 75);
  });

  test('back-filling an old day corrects the whole curve', () {
    final habit = buildHabit(startedDaysAgo: 5);
    final withoutBackfill =
        calculator.buildStats(habit: habit, logs: const [], today: today);
    final withBackfill = calculator.buildStats(
      habit: habit,
      logs: [doneOn(AppDateUtils.addDays(today, -4))],
      today: today,
    );

    expect(
      withBackfill.currentScore,
      greaterThan(withoutBackfill.currentScore),
    );
  });
}
