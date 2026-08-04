import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/habit_detail.dart';
import '../entities/habit_log.dart';
import '../repositories/habit_repository.dart';
import '../services/health_score_calculator.dart';

class GetHabitDetailParams {
  final String habitId;
  final int trendWindowDays;

  const GetHabitDetailParams(this.habitId, {this.trendWindowDays = 30});
}

class GetHabitDetail implements UseCase<HabitDetail, GetHabitDetailParams> {
  final HabitRepository repository;
  final HealthScoreCalculator calculator;

  const GetHabitDetail(this.repository, this.calculator);

  @override
  Future<Either<Failure, HabitDetail>> call(GetHabitDetailParams params) async {
    final habitResult = await repository.getHabitById(params.habitId);

    return habitResult.fold(
      (failure) => Left(failure),
      (habit) async {
        final logsResult = await repository.getLogsForHabit(habit.id);
        return logsResult.fold(
          (failure) => Left(failure),
          (logs) {
            final stats = calculator.buildStats(
              habit: habit,
              logs: logs,
              today: DateTime.now(),
              trendWindowDays: params.trendWindowDays,
            );
            return Right(
              HabitDetail(
                habit: habit,
                stats: stats,
                logsByDay: <String, HabitLog>{
                  for (final log in logs) AppDateUtils.dayKey(log.date): log,
                },
              ),
            );
          },
        );
      },
    );
  }
}
