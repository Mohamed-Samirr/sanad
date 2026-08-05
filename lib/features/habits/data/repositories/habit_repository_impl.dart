import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain_exports.dart';
import '../datasources/habit_local_data_source.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  const HabitRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Habit>>> getHabits({
    bool includeArchived = false,
  }) async {
    try {
      final habits = localDataSource
          .getHabits()
          .map((model) => model.toEntity())
          .where((habit) => includeArchived || !habit.isArchived)
          .toList()
        ..sort((a, b) => a.timeOfDay.index.compareTo(b.timeOfDay.index));
      return Right(habits);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Habit>> getHabitById(String id) async {
    try {
      return Right(localDataSource.getHabitById(id).toEntity());
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveHabit(Habit habit) async {
    try {
      await localDataSource.putHabit(HabitModel.fromEntity(habit));
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHabit(String id) async {
    try {
      await localDataSource.deleteHabit(id);
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> archiveHabit(String id) async {
    try {
      final habit = localDataSource.getHabitById(id).toEntity();
      await localDataSource.putHabit(
        HabitModel.fromEntity(habit.copyWith(isArchived: true)),
      );
      return const Right(unit);
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreHabit(String id) async {
    try {
      final habit = localDataSource.getHabitById(id).toEntity();
      await localDataSource.putHabit(
        HabitModel.fromEntity(habit.copyWith(isArchived: false)),
      );
      return const Right(unit);
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<HabitLog>>> getLogsForHabit(String habitId) async {
    try {
      final logs = localDataSource
          .getLogsForHabit(habitId)
          .map((model) => model.toEntity())
          .toList();
      return Right(logs);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<HabitLog>>> getAllLogs() async {
    try {
      final logs =
          localDataSource.getAllLogs().map((model) => model.toEntity()).toList();
      return Right(logs);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setLog({
    required String habitId,
    required DateTime date,
    required HabitLogStatus status,
    String? note,
  }) async {
    try {
      final normalised = AppDateUtils.startOfDay(date);
      await localDataSource.putLog(
        HabitLogModel(
          habitId: habitId,
          date: normalised,
          statusIndex: status.index,
          note: note,
          loggedAt: DateTime.now(),
        ),
      );
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeLog({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      await localDataSource.deleteLog(habitId, AppDateUtils.startOfDay(date));
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<void> watchChanges() => localDataSource.watchChanges();
}
