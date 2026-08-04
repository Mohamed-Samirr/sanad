import 'habit.dart';
import 'habit_log.dart';

/// Row model for the habits list.
class HabitSummary {
  final Habit habit;
  final HabitLog? todayLog;
  final int currentStreak;
  final bool isScheduledToday;

  const HabitSummary({
    required this.habit,
    required this.currentStreak,
    required this.isScheduledToday,
    this.todayLog,
  });

  bool get isDoneToday => todayLog?.isDone ?? false;
}
