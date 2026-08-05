import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/archived_habit.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';
import '../repositories/habit_repository.dart';

class GetArchivedHabits implements UseCase<List<ArchivedHabit>, NoParams> {
  final HabitRepository repository;

  const GetArchivedHabits(this.repository);

  @override
  Future<Either<Failure, List<ArchivedHabit>>> call(NoParams params) async {
    final habitsResult = await repository.getHabits(includeArchived: true);

    return habitsResult.fold(
      (failure) => Left(failure),
      (habits) async {
        final archived = habits.where((Habit habit) => habit.isArchived).toList();
        if (archived.isEmpty) return const Right(<ArchivedHabit>[]);

        // One read of every log, then a count per habit — cheaper than a
        // getLogsForHabit call for each one.
        final logsResult = await repository.getAllLogs();
        return logsResult.fold(
          (failure) => Left(failure),
          (logs) {
            final counts = <String, int>{};
            for (final HabitLog log in logs) {
              counts[log.habitId] = (counts[log.habitId] ?? 0) + 1;
            }

            return Right(
              archived
                  .map((habit) => ArchivedHabit(
                        habit: habit,
                        logCount: counts[habit.id] ?? 0,
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
