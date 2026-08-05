import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/habit_repository.dart';

class ClearHabitLogParams {
  final String habitId;
  final DateTime date;

  const ClearHabitLogParams({required this.habitId, required this.date});
}

/// Removes the log for one day, returning it to "no entry".
///
/// Only positive intent is stored, so clearing is a delete rather than a
/// third status: a scheduled day with no log is read back as a miss, and an
/// unscheduled one as neutral. That is decided by the calculator at read
/// time, not recorded here.
class ClearHabitLog implements UseCase<Unit, ClearHabitLogParams> {
  final HabitRepository repository;

  const ClearHabitLog(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ClearHabitLogParams params) {
    return repository.removeLog(habitId: params.habitId, date: params.date);
  }
}
