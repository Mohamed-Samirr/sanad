import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/habit_repository.dart';

/// Puts an archived habit back on the active list.
///
/// The logs were never touched by archiving, so restoring needs no repair
/// step — the score curve is rebuilt from the habit's first day on the next
/// read and picks the history straight back up.
class RestoreHabit implements UseCase<Unit, String> {
  final HabitRepository repository;

  const RestoreHabit(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String habitId) =>
      repository.restoreHabit(habitId);
}
