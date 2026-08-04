import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/habit_repository.dart';

class DeleteHabit implements UseCase<Unit, String> {
  final HabitRepository repository;

  const DeleteHabit(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String habitId) =>
      repository.deleteHabit(habitId);
}

/// Keeps the history but removes the habit from the active list.
class ArchiveHabit implements UseCase<Unit, String> {
  final HabitRepository repository;

  const ArchiveHabit(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String habitId) =>
      repository.archiveHabit(habitId);
}
