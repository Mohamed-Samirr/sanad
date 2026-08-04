import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/habit_log.dart';
import '../repositories/habit_repository.dart';

class ToggleHabitLogParams {
  final String habitId;
  final DateTime date;
  final bool isCurrentlyDone;
  final String? note;

  const ToggleHabitLogParams({
    required this.habitId,
    required this.date,
    required this.isCurrentlyDone,
    this.note,
  });
}

/// Marks a day done, or clears it when it was already done.
class ToggleHabitLog implements UseCase<Unit, ToggleHabitLogParams> {
  final HabitRepository repository;

  const ToggleHabitLog(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ToggleHabitLogParams params) {
    if (params.date.isAfter(DateTime.now())) {
      return Future.value(
        const Left(ValidationFailure('You cannot log a day that has not happened yet.')),
      );
    }

    if (params.isCurrentlyDone) {
      return repository.removeLog(habitId: params.habitId, date: params.date);
    }

    return repository.setLog(
      habitId: params.habitId,
      date: params.date,
      status: HabitLogStatus.done,
      note: params.note,
    );
  }
}
