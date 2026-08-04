import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';
import '../entities/habit_summary.dart';
import '../repositories/habit_repository.dart';
import '../services/health_score_calculator.dart';

class GetHabitSummaries implements UseCase<List<HabitSummary>, NoParams> {
  final HabitRepository repository;
  final HealthScoreCalculator calculator;

  const GetHabitSummaries(this.repository, this.calculator);

  @override
  Future<Either<Failure, List<HabitSummary>>> call(NoParams params) async {
    final habitsResult = await repository.getHabits();

    return habitsResult.fold(
      (failure) => Left(failure),
      (habits) async {
        final logsResult = await repository.getAllLogs();
        return logsResult.fold(
          (failure) => Left(failure),
          (logs) {
            final today = DateTime.now();
            final todayKey = AppDateUtils.dayKey(today);

            final grouped = <String, List<HabitLog>>{};
            for (final log in logs) {
              grouped.putIfAbsent(log.habitId, () => []).add(log);
            }

            final summaries = habits.map((Habit habit) {
              final habitLogs = grouped[habit.id] ?? const <HabitLog>[];
              final stats = calculator.buildStats(
                habit: habit,
                logs: habitLogs,
                today: today,
              );
              HabitLog? todayLog;
              for (final log in habitLogs) {
                if (AppDateUtils.dayKey(log.date) == todayKey) {
                  todayLog = log;
                  break;
                }
              }
              return HabitSummary(
                habit: habit,
                currentStreak: stats.currentStreak,
                isScheduledToday: habit.isScheduledOn(today),
                todayLog: todayLog,
              );
            }).toList();

            return Right(summaries);
          },
        );
      },
    );
  }
}
