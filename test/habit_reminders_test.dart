import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/core/usecase/usecase.dart';
import 'package:sanad/features/habits/domain/repositories/habit_repository.dart';
import 'package:sanad/features/habits/domain/services/habit_reminder_scheduler.dart';
import 'package:sanad/features/habits/domain/usecases/sync_habit_reminders.dart';
import 'package:sanad/features/habits/domain_exports.dart';

class _FakeScheduler implements HabitReminderScheduler {
  bool permitted = true;
  bool cancelledAll = false;
  List<HabitReminder>? synced;

  @override
  Future<bool> ensurePermission() async => permitted;

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<void> syncReminders(List<HabitReminder> reminders) async {
    synced = reminders;
  }

  @override
  Future<void> cancelAll() async => cancelledAll = true;
}

class _FakeRepository implements HabitRepository {
  _FakeRepository(this.habits);

  final List<Habit> habits;

  @override
  Future<Either<Failure, List<Habit>>> getHabits({
    bool includeArchived = false,
  }) async =>
      Right(habits.where((h) => includeArchived || !h.isArchived).toList());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

Habit habit({
  String id = 'h1',
  int? reminderMinutes = 8 * 60,
  HabitScheduleType schedule = HabitScheduleType.daily,
  List<int> weekdays = const [],
  bool archived = false,
  DateTime? startDate,
}) =>
    Habit(
      id: id,
      name: 'Walk',
      iconCodePoint: 0xf5ca,
      colorHex: 'FFB9A9FF',
      timeOfDay: HabitTimeOfDay.morning,
      scheduleType: schedule,
      scheduledWeekdays: weekdays,
      startDate: startDate ?? DateTime(2026, 1, 1),
      reminderMinutes: reminderMinutes,
      isArchived: archived,
    );

void main() {
  group('buildReminders', () {
    // A Wednesday, 06:00 — before the 08:00 reminder.
    final from = DateTime(2026, 3, 4, 6);

    test('a daily habit fills the whole window', () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit()],
        from: from,
        windowDays: 14,
      );

      expect(reminders.single.occurrences, hasLength(14));
    });

    test('every occurrence lands on the requested wall-clock time', () {
      // This is the DST guarantee: occurrences are built as local wall-clock
      // DateTimes, so 08:00 stays 08:00 on every day in the window no matter
      // what the UTC offset does in between.
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit(reminderMinutes: 8 * 60 + 30)],
        from: from,
        windowDays: 14,
      );

      for (final at in reminders.single.occurrences) {
        expect(at.hour, 8);
        expect(at.minute, 30);
      }
    });

    test("today is skipped once its time has already passed", () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit()],
        // 09:00, after the 08:00 reminder.
        from: DateTime(2026, 3, 4, 9),
        windowDays: 3,
      );

      final days = reminders.single.occurrences.map((d) => d.day);
      expect(days, [5, 6], reason: 'the 4th is already behind us');
    });

    test('today is included when its time is still ahead', () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit()],
        from: from,
        windowDays: 3,
      );

      expect(reminders.single.occurrences.first.day, 4);
    });

    test('a weekday habit only fires on its own days', () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [
          habit(
            schedule: HabitScheduleType.weekdays,
            // Monday and Friday.
            weekdays: const [1, 5],
          ),
        ],
        from: from,
        windowDays: 14,
      );

      for (final at in reminders.single.occurrences) {
        expect([DateTime.monday, DateTime.friday], contains(at.weekday));
      }
      expect(reminders.single.occurrences, hasLength(4));
    });

    test('a habit with no reminder set is left out', () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit(reminderMinutes: null)],
        from: from,
      );

      expect(reminders, isEmpty);
    });

    test('an archived habit is left out', () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit(archived: true)],
        from: from,
      );

      expect(reminders, isEmpty);
    });

    test('nothing is scheduled before the habit starts', () {
      final reminders = SyncHabitReminders.buildReminders(
        habits: [habit(startDate: DateTime(2026, 3, 10))],
        from: from,
        windowDays: 14,
      );

      for (final at in reminders.single.occurrences) {
        expect(at.isBefore(DateTime(2026, 3, 10)), isFalse);
      }
    });
  });

  group('SyncHabitReminders', () {
    final habits = [habit()];

    test('schedules when permission is already granted', () async {
      final scheduler = _FakeScheduler();

      final result = await SyncHabitReminders(
        _FakeRepository(habits),
        scheduler,
      )(const NoParams());

      expect(result.getOrElse(() => 0), greaterThan(0));
      expect(scheduler.synced, isNotNull);
    });

    test('never prompts, and clears the queue, when permission is absent',
        () async {
      final scheduler = _FakeScheduler()..permitted = false;

      final result = await SyncHabitReminders(
        _FakeRepository(habits),
        scheduler,
      )(const NoParams());

      expect(result.getOrElse(() => -1), 0);
      expect(scheduler.cancelledAll, isTrue);
      expect(scheduler.synced, isNull,
          reason: 'nothing may be scheduled without permission');
    });
  });
}
