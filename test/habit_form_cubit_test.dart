import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/core/utils/date_utils.dart';
import 'package:sanad/features/habits/domain/repositories/habit_repository.dart';
import 'package:sanad/features/habits/domain/services/habit_reminder_scheduler.dart';
import 'package:sanad/features/habits/domain/usecases/request_reminder_permission.dart';
import 'package:sanad/features/habits/domain/usecases/save_habit.dart';
import 'package:sanad/features/habits/domain_exports.dart';
import 'package:sanad/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:sanad/features/habits/presentation/widgets/habit_icon.dart';

/// Captures what the form actually asked to be written. Only [saveHabit] is
/// exercised here; the rest of the interface is not reachable from the form.
class _CapturingRepository implements HabitRepository {
  Habit? saved;
  Failure? failure;

  @override
  Future<Either<Failure, Unit>> saveHabit(Habit habit) async {
    if (failure != null) return Left(failure!);
    saved = habit;
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

/// Grants by default; flip [granted] to exercise a refusal.
class _FakeScheduler implements HabitReminderScheduler {
  bool granted = true;
  bool asked = false;

  @override
  Future<bool> ensurePermission() async {
    asked = true;
    return granted;
  }

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<void> syncReminders(List<HabitReminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  late _CapturingRepository repository;
  late SaveHabit saveHabit;
  late _FakeScheduler scheduler;

  setUp(() {
    repository = _CapturingRepository();
    saveHabit = SaveHabit(repository);
    scheduler = _FakeScheduler();
  });

  HabitFormCubit build({Habit? initial}) => HabitFormCubit(
        saveHabit: saveHabit,
        requestReminderPermission: RequestReminderPermission(scheduler),
        initial: initial,
      );

  Habit existingHabit() => Habit(
        id: 'habit-1',
        name: 'Gym',
        iconCodePoint: 0xf767,
        colorHex: 'FF4ECDC4',
        timeOfDay: HabitTimeOfDay.morning,
        scheduleType: HabitScheduleType.weekdays,
        scheduledWeekdays: const [1, 3, 5],
        startDate: DateTime(2026, 1, 10),
        targetNote: '45 minutes',
        isArchived: true,
        linkedToolActionId: 'tool-9',
      );

  group('creating', () {
    test('starts today and never in the future', () {
      final cubit = build();
      final today = AppDateUtils.startOfDay(DateTime.now());

      expect(cubit.state.startDate, today);

      cubit.setStartDate(AppDateUtils.addDays(today, 5));
      expect(cubit.state.startDate, today,
          reason: 'a habit cannot begin before there is anything to log');

      cubit.setStartDate(AppDateUtils.addDays(today, -3));
      expect(cubit.state.startDate, AppDateUtils.addDays(today, -3));
    });

    test('an empty name is refused inline and nothing is written', () async {
      final cubit = build()..setName('   ');

      await cubit.submit();

      expect(cubit.state.nameErrorCode, FailureCode.nameRequired);
      expect(cubit.state.status, HabitFormStatus.editing);
      expect(repository.saved, isNull);
    });

    test('weekday schedule with no day selected is refused inline', () async {
      final cubit = build()
        ..setName('Walk')
        ..setScheduleType(HabitScheduleType.weekdays);

      await cubit.submit();

      expect(cubit.state.scheduleErrorCode, FailureCode.weekdayRequired);
      expect(repository.saved, isNull);
    });

    test('a valid habit is written and the form reports saved', () async {
      final cubit = build()
        ..setName('  Walk  ')
        ..setScheduleType(HabitScheduleType.weekdays)
        ..toggleWeekday(3)
        ..toggleWeekday(1)
        ..setTimeOfDay(HabitTimeOfDay.evening)
        ..setTargetNote('  20 minutes  ');

      // Awaited separately: setting a reminder asks the OS for permission, so
      // it is async and a cascade would race the save.
      await cubit.setReminder(const TimeOfDay(hour: 7, minute: 30));
      await cubit.submit();

      final saved = repository.saved!;
      expect(saved.name, 'Walk', reason: 'name is trimmed');
      expect(saved.targetNote, '20 minutes');
      expect(saved.scheduledWeekdays, [1, 3], reason: 'weekdays are sorted');
      expect(saved.timeOfDay, HabitTimeOfDay.evening);
      expect(saved.reminderMinutes, 7 * 60 + 30);
      expect(saved.id, isNotEmpty);
      expect(cubit.state.status, HabitFormStatus.saved);
    });

    test('an empty target note is stored as null, not an empty string', () async {
      final cubit = build()
        ..setName('Read')
        ..setTargetNote('   ');

      await cubit.submit();

      expect(repository.saved!.targetNote, isNull);
    });

    test('toggling a weekday twice removes it', () {
      final cubit = build()
        ..toggleWeekday(2)
        ..toggleWeekday(2);

      expect(cubit.state.scheduledWeekdays, isEmpty);
    });

    test('the weekly target is clamped to 1-7', () {
      final cubit = build()..setTimesPerWeek(99);
      expect(cubit.state.timesPerWeek, 7);

      cubit.setTimesPerWeek(0);
      expect(cubit.state.timesPerWeek, 1);
    });
  });

  group('editing', () {
    test('seeds every field from the habit being edited', () {
      final cubit = build(initial: existingHabit());

      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.name, 'Gym');
      expect(cubit.state.scheduledWeekdays, [1, 3, 5]);
      expect(cubit.state.targetNote, '45 minutes');
      expect(cubit.state.startDate, DateTime(2026, 1, 10));
    });

    test('preserves id, start date, archive flag and toolbox link', () async {
      final cubit = build(initial: existingHabit())..setName('Gym & swim');

      await cubit.submit();

      final saved = repository.saved!;
      expect(saved.id, 'habit-1', reason: 'the logs are keyed on this id');
      expect(saved.startDate, DateTime(2026, 1, 10));
      expect(saved.isArchived, isTrue,
          reason: 'editing an archived habit must not silently restore it');
      expect(saved.linkedToolActionId, 'tool-9');
      expect(saved.name, 'Gym & swim');
    });

    test('clearing the target note actually clears it', () async {
      // The regression copyWith would cause: a null note reads as "unchanged"
      // and the old value survives.
      final cubit = build(initial: existingHabit())..setTargetNote('');

      await cubit.submit();

      expect(repository.saved!.targetNote, isNull);
    });

    test('clearing the reminder actually clears it', () async {
      final initial = existingHabit();
      final cubit = build(
        initial: Habit(
          id: initial.id,
          name: initial.name,
          iconCodePoint: initial.iconCodePoint,
          colorHex: initial.colorHex,
          timeOfDay: initial.timeOfDay,
          scheduleType: initial.scheduleType,
          scheduledWeekdays: initial.scheduledWeekdays,
          startDate: initial.startDate,
          reminderMinutes: 480,
        ),
      );
      expect(cubit.state.reminderMinutes, 480);

      await cubit.setReminder(null);
      await cubit.submit();

      expect(repository.saved!.reminderMinutes, isNull);
    });

    test('switching schedule type drops the fields it no longer uses',
        () async {
      final cubit = build(initial: existingHabit())
        ..setScheduleType(HabitScheduleType.daily);

      await cubit.submit();

      final saved = repository.saved!;
      expect(saved.scheduleType, HabitScheduleType.daily);
      expect(saved.scheduledWeekdays, isEmpty,
          reason: 'stale weekdays would misreport which days were scheduled');
      expect(saved.timesPerWeek, isNull);
    });

    test('switching to timesPerWeek writes the target and drops weekdays',
        () async {
      final cubit = build(initial: existingHabit())
        ..setScheduleType(HabitScheduleType.timesPerWeek)
        ..setTimesPerWeek(4);

      await cubit.submit();

      expect(repository.saved!.timesPerWeek, 4);
      expect(repository.saved!.scheduledWeekdays, isEmpty);
    });
  });

  group('reminders', () {
    test('asks for permission only when a time is actually set', () async {
      final cubit = build();
      expect(scheduler.asked, isFalse, reason: 'never prompt on open');

      await cubit.setReminder(const TimeOfDay(hour: 7, minute: 0));

      expect(scheduler.asked, isTrue);
      expect(cubit.state.reminderMinutes, 7 * 60);
    });

    test('clearing a reminder does not prompt', () async {
      final cubit = build();

      await cubit.setReminder(null);

      expect(scheduler.asked, isFalse);
      expect(cubit.state.reminderMinutes, isNull);
    });

    test('a refused permission leaves no reminder behind', () async {
      scheduler.granted = false;
      final cubit = build();

      await cubit.setReminder(const TimeOfDay(hour: 7, minute: 0));

      expect(cubit.state.reminderMinutes, isNull,
          reason: 'a stored time that can never fire is a broken promise');
      expect(cubit.state.failure, isNotNull);
    });

    test('a refused permission still lets the habit be saved', () async {
      scheduler.granted = false;
      final cubit = build()..setName('Walk');

      await cubit.setReminder(const TimeOfDay(hour: 7, minute: 0));
      await cubit.submit();

      expect(repository.saved, isNotNull);
      expect(repository.saved!.reminderMinutes, isNull);
    });
  });

  group('icon catalogue', () {
    test('the default icon is one the picker can actually show', () {
      // If these drift apart, a new habit opens the form with nothing
      // selected and release builds lose the glyph.
      expect(
        HabitIcons.catalogue.map((icon) => icon.codePoint),
        contains(build().state.iconCodePoint),
      );
    });

    test('an unknown codepoint falls back instead of rendering nothing', () {
      expect(HabitIcons.resolve(0x0), HabitIcons.fallback);
    });

    test('every catalogue entry resolves back to itself', () {
      for (final icon in HabitIcons.catalogue) {
        expect(HabitIcons.resolve(icon.codePoint), icon);
      }
    });
  });

  group('failures', () {
    test('a repository failure surfaces and the form stays open', () async {
      repository.failure = const CacheFailure();
      final cubit = build()..setName('Walk');

      await cubit.submit();

      expect(cubit.state.status, HabitFormStatus.failure);
      expect(cubit.state.failure, const CacheFailure());
    });

    test('a ValidationFailure from SaveHabit is surfaced, not swallowed',
        () async {
      repository.failure = const ValidationFailure('Something is off.');
      final cubit = build()..setName('Walk');

      await cubit.submit();

      expect(cubit.state.failure?.message, 'Something is off.');
    });

    test('the error clears on the next edit so it shows once', () async {
      repository.failure = const CacheFailure();
      final cubit = build()..setName('Walk');
      await cubit.submit();
      expect(cubit.state.failure, isNotNull);

      cubit.setName('Walk more');
      expect(cubit.state.failure, isNull);
    });
  });
}
