import 'habit.dart';
import 'habit_log.dart';
import 'habit_stats.dart';

/// Everything the detail screen needs, assembled in one use case.
class HabitDetail {
  final Habit habit;
  final HabitStats stats;

  /// Keyed by `yyyy-MM-dd` for O(1) calendar lookups.
  final Map<String, HabitLog> logsByDay;

  const HabitDetail({
    required this.habit,
    required this.stats,
    required this.logsByDay,
  });
}
