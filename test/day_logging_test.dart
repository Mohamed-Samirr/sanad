import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/habits/domain/repositories/habit_repository.dart';
import 'package:sanad/features/habits/domain/usecases/clear_habit_log.dart';
import 'package:sanad/features/habits/domain/usecases/set_habit_log.dart';
import 'package:sanad/features/habits/domain_exports.dart';

class _CapturingRepository implements HabitRepository {
  String? setHabitId;
  DateTime? setDate;
  HabitLogStatus? setStatus;
  String? setNote;

  String? removedHabitId;
  DateTime? removedDate;

  Failure? failure;

  @override
  Future<Either<Failure, Unit>> setLog({
    required String habitId,
    required DateTime date,
    required HabitLogStatus status,
    String? note,
  }) async {
    if (failure != null) return Left(failure!);
    setHabitId = habitId;
    setDate = date;
    setStatus = status;
    setNote = note;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> removeLog({
    required String habitId,
    required DateTime date,
  }) async {
    if (failure != null) return Left(failure!);
    removedHabitId = habitId;
    removedDate = date;
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

void main() {
  late _CapturingRepository repository;

  setUp(() => repository = _CapturingRepository());

  group('SetHabitLog', () {
    test('records a done day', () async {
      final date = DateTime.now().subtract(const Duration(days: 1));

      final result = await SetHabitLog(repository)(
        SetHabitLogParams(
          habitId: 'h1',
          date: date,
          status: HabitLogStatus.done,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(repository.setHabitId, 'h1');
      expect(repository.setStatus, HabitLogStatus.done);
    });

    test('records a skipped day — the status the toggle could not express',
        () async {
      await SetHabitLog(repository)(
        SetHabitLogParams(
          habitId: 'h1',
          date: DateTime.now(),
          status: HabitLogStatus.skipped,
          note: 'Travelling',
        ),
      );

      expect(repository.setStatus, HabitLogStatus.skipped);
      expect(repository.setNote, 'Travelling');
    });

    test('trims the note and stores a blank one as null', () async {
      await SetHabitLog(repository)(
        SetHabitLogParams(
          habitId: 'h1',
          date: DateTime.now(),
          status: HabitLogStatus.done,
          note: '   ',
        ),
      );
      expect(repository.setNote, isNull);

      await SetHabitLog(repository)(
        SetHabitLogParams(
          habitId: 'h1',
          date: DateTime.now(),
          status: HabitLogStatus.done,
          note: '  felt good  ',
        ),
      );
      expect(repository.setNote, 'felt good');
    });

    test('refuses a day that has not happened yet', () async {
      final result = await SetHabitLog(repository)(
        SetHabitLogParams(
          habitId: 'h1',
          date: DateTime.now().add(const Duration(days: 2)),
          status: HabitLogStatus.done,
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(repository.setHabitId, isNull, reason: 'nothing may be written');
    });

    test('passes a storage failure through instead of throwing', () async {
      repository.failure = const CacheFailure();

      final result = await SetHabitLog(repository)(
        SetHabitLogParams(
          habitId: 'h1',
          date: DateTime.now(),
          status: HabitLogStatus.done,
        ),
      );

      expect(result, const Left<Failure, Unit>(CacheFailure()));
    });
  });

  group('ClearHabitLog', () {
    test('removes the entry for the day', () async {
      final date = DateTime(2026, 3, 1);

      final result = await ClearHabitLog(repository)(
        ClearHabitLogParams(habitId: 'h1', date: date),
      );

      expect(result.isRight(), isTrue);
      expect(repository.removedHabitId, 'h1');
      expect(repository.removedDate, date);
    });
  });
}
