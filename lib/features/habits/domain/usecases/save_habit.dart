import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class SaveHabit implements UseCase<Unit, Habit> {
  final HabitRepository repository;

  const SaveHabit(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Habit habit) {
    if (habit.name.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure(
          'Give the habit a name.',
          code: FailureCode.nameRequired,
        )),
      );
    }
    if (habit.scheduleType == HabitScheduleType.weekdays &&
        habit.scheduledWeekdays.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(
          'Pick at least one day of the week.',
          code: FailureCode.weekdayRequired,
        )),
      );
    }
    if (habit.scheduleType == HabitScheduleType.timesPerWeek &&
        (habit.timesPerWeek == null ||
            habit.timesPerWeek! < 1 ||
            habit.timesPerWeek! > 7)) {
      return Future.value(
        const Left(ValidationFailure(
          'Set a weekly target between 1 and 7.',
          code: FailureCode.weeklyTargetRange,
        )),
      );
    }
    return repository.saveHabit(habit);
  }
}
