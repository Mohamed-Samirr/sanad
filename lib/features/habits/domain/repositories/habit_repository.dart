import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';

abstract class HabitRepository {
  Future<Either<Failure, List<Habit>>> getHabits({bool includeArchived = false});

  Future<Either<Failure, Habit>> getHabitById(String id);

  Future<Either<Failure, Unit>> saveHabit(Habit habit);

  Future<Either<Failure, Unit>> deleteHabit(String id);

  Future<Either<Failure, Unit>> archiveHabit(String id);

  Future<Either<Failure, List<HabitLog>>> getLogsForHabit(String habitId);

  Future<Either<Failure, List<HabitLog>>> getAllLogs();

  Future<Either<Failure, Unit>> setLog({
    required String habitId,
    required DateTime date,
    required HabitLogStatus status,
    String? note,
  });

  Future<Either<Failure, Unit>> removeLog({
    required String habitId,
    required DateTime date,
  });

  /// Emits whenever any habit or log changes, so open screens can refresh.
  Stream<void> watchChanges();
}
