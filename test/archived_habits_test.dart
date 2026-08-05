import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/core/usecase/usecase.dart';
import 'package:sanad/features/habits/domain/repositories/habit_repository.dart';
import 'package:sanad/features/habits/domain/usecases/get_archived_habits.dart';
import 'package:sanad/features/habits/domain/usecases/restore_habit.dart';
import 'package:sanad/features/habits/domain_exports.dart';

class _FakeRepository implements HabitRepository {
  _FakeRepository({this.habits = const [], this.logs = const []});

  List<Habit> habits;
  List<HabitLog> logs;

  Failure? habitsFailure;
  Failure? logsFailure;

  bool getAllLogsCalled = false;
  String? restoredId;

  @override
  Future<Either<Failure, List<Habit>>> getHabits({
    bool includeArchived = false,
  }) async {
    if (habitsFailure != null) return Left(habitsFailure!);
    return Right(
      habits.where((h) => includeArchived || !h.isArchived).toList(),
    );
  }

  @override
  Future<Either<Failure, List<HabitLog>>> getAllLogs() async {
    getAllLogsCalled = true;
    if (logsFailure != null) return Left(logsFailure!);
    return Right(logs);
  }

  @override
  Future<Either<Failure, Unit>> restoreHabit(String id) async {
    restoredId = id;
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

Habit habit(String id, {bool archived = false}) => Habit(
      id: id,
      name: 'Habit $id',
      iconCodePoint: 0xf5ca,
      colorHex: 'FFB9A9FF',
      timeOfDay: HabitTimeOfDay.anytime,
      scheduleType: HabitScheduleType.daily,
      startDate: DateTime(2026, 1, 1),
      isArchived: archived,
    );

HabitLog log(String habitId, int day) => HabitLog(
      habitId: habitId,
      date: DateTime(2026, 2, day),
      status: HabitLogStatus.done,
      loggedAt: DateTime(2026, 2, day),
    );

void main() {
  group('GetArchivedHabits', () {
    test('returns only the archived ones', () async {
      final repository = _FakeRepository(
        habits: [habit('a'), habit('b', archived: true)],
      );

      final result = await GetArchivedHabits(repository)(const NoParams());

      final entries = result.getOrElse(() => []);
      expect(entries.map((e) => e.habit.id), ['b']);
    });

    test('counts the logged days that a delete would take with it', () async {
      final repository = _FakeRepository(
        habits: [habit('b', archived: true), habit('c', archived: true)],
        logs: [log('b', 1), log('b', 2), log('b', 3), log('c', 1)],
      );

      final result = await GetArchivedHabits(repository)(const NoParams());
      final entries = result.getOrElse(() => []);

      expect(entries.firstWhere((e) => e.habit.id == 'b').logCount, 3);
      expect(entries.firstWhere((e) => e.habit.id == 'c').logCount, 1);
      expect(entries.every((e) => e.hasHistory), isTrue);
    });

    test('reports no history for an archived habit that was never logged',
        () async {
      final repository = _FakeRepository(habits: [habit('b', archived: true)]);

      final result = await GetArchivedHabits(repository)(const NoParams());
      final entry = result.getOrElse(() => []).single;

      expect(entry.logCount, 0);
      expect(entry.hasHistory, isFalse);
    });

    test('skips the log read entirely when nothing is archived', () async {
      final repository = _FakeRepository(habits: [habit('a')]);

      final result = await GetArchivedHabits(repository)(const NoParams());

      expect(result.getOrElse(() => []), isEmpty);
      expect(repository.getAllLogsCalled, isFalse);
    });

    test('passes a habits failure through', () async {
      final repository = _FakeRepository()..habitsFailure = const CacheFailure();

      final result = await GetArchivedHabits(repository)(const NoParams());

      expect(result.isLeft(), isTrue);
    });

    test('passes a logs failure through', () async {
      final repository = _FakeRepository(habits: [habit('b', archived: true)])
        ..logsFailure = const CacheFailure();

      final result = await GetArchivedHabits(repository)(const NoParams());

      expect(result.isLeft(), isTrue);
    });
  });

  group('RestoreHabit', () {
    test('asks the repository to restore that id', () async {
      final repository = _FakeRepository();

      final result = await RestoreHabit(repository)('b');

      expect(result.isRight(), isTrue);
      expect(repository.restoredId, 'b');
    });
  });
}
