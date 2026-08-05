import '../entities/habit.dart';

/// One habit's upcoming reminders, already resolved to concrete moments.
///
/// The scheduler is deliberately given instants rather than a habit and a
/// rule: deciding *which* days a habit is due is domain logic and stays
/// testable in plain Dart, while the platform side only has to fire at times
/// it is handed.
class HabitReminder {
  final String habitId;
  final String habitName;
  final String? targetNote;

  /// Local wall-clock moments, soonest first.
  final List<DateTime> occurrences;

  const HabitReminder({
    required this.habitId,
    required this.habitName,
    required this.occurrences,
    this.targetNote,
  });
}

/// Port for the platform notification layer.
///
/// Pure Dart so the domain never reaches for Flutter. The implementation
/// lives in `core/services/notification_service.dart`.
abstract class HabitReminderScheduler {
  /// Asks the OS for permission, returning whether reminders may be shown.
  /// Called the moment a user sets their first reminder — never at launch.
  Future<bool> ensurePermission();

  /// Whether permission has already been granted, without prompting.
  Future<bool> hasPermission();

  /// Replaces every scheduled reminder with [reminders].
  Future<void> syncReminders(List<HabitReminder> reminders);

  Future<void> cancelAll();
}

/// How far ahead reminders are scheduled.
///
/// Reminders are written as individual one-shot notifications rather than one
/// repeating rule, and the window is topped up on every app start and on every
/// habit change. See [Habit] usage in `SyncHabitReminders` for why.
const int kReminderWindowDays = 14;
