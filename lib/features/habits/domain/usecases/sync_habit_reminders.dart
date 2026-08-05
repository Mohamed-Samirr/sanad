import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_reminder_scheduler.dart';

/// Rebuilds the whole reminder schedule from the current habits.
///
/// Always a full rebuild rather than an incremental edit: reminders have to
/// stay correct across create, edit, delete, archive, restore and a changed
/// clock, and reconciling each of those separately is how schedules drift out
/// of sync with their habits. Rebuilding is cheap at this scale.
class SyncHabitReminders implements UseCase<int, NoParams> {
  final HabitRepository repository;
  final HabitReminderScheduler scheduler;

  const SyncHabitReminders(this.repository, this.scheduler);

  /// Returns how many individual reminders were scheduled.
  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    final habitsResult = await repository.getHabits();

    return habitsResult.fold(
      (failure) => Left(failure),
      (habits) async {
        // Never prompt here. If the user has not granted permission there is
        // nothing to schedule, and asking at startup is exactly what the app
        // promises not to do.
        if (!await scheduler.hasPermission()) {
          await scheduler.cancelAll();
          return const Right(0);
        }

        final reminders = buildReminders(
          habits: habits,
          from: DateTime.now(),
        );

        await scheduler.syncReminders(reminders);
        return Right(
          reminders.fold<int>(0, (sum, r) => sum + r.occurrences.length),
        );
      },
    );
  }

  /// Pure: the next [kReminderWindowDays] of reminders for [habits].
  ///
  /// Exposed for testing — this is where the schedule is actually decided.
  static List<HabitReminder> buildReminders({
    required List<Habit> habits,
    required DateTime from,
    int windowDays = kReminderWindowDays,
  }) {
    final reminders = <HabitReminder>[];
    final today = AppDateUtils.startOfDay(from);

    for (final habit in habits) {
      final minutes = habit.reminderMinutes;
      if (minutes == null || habit.isArchived) continue;

      final occurrences = <DateTime>[];
      for (var offset = 0; offset < windowDays; offset++) {
        final day = AppDateUtils.addDays(today, offset);
        if (!habit.isScheduledOn(day)) continue;

        // Built as a local wall-clock DateTime on purpose. Dart resolves this
        // against the OS's own timezone rules, so a reminder set for 08:00
        // stays 08:00 on either side of a DST change instead of sliding by an
        // hour the way a fixed repeating offset would.
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          minutes ~/ 60,
          minutes % 60,
        );

        if (at.isAfter(from)) occurrences.add(at);
      }

      if (occurrences.isEmpty) continue;

      reminders.add(
        HabitReminder(
          habitId: habit.id,
          habitName: habit.name,
          targetNote: habit.targetNote,
          occurrences: occurrences,
        ),
      );
    }

    return reminders;
  }
}
