import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/habit_log.dart';
import '../repositories/habit_repository.dart';

class SetHabitLogParams {
  final String habitId;
  final DateTime date;
  final HabitLogStatus status;
  final String? note;

  const SetHabitLogParams({
    required this.habitId,
    required this.date,
    required this.status,
    this.note,
  });
}

/// Writes an explicit outcome for one day.
///
/// [ToggleHabitLog] flips a day between done and nothing, which is all the
/// one-tap check button needs. This is the deliberate version behind the day
/// sheet: it can record a skip, and it can carry a note. Writing is
/// idempotent because the log key is `habitId_yyyy-MM-dd`, so re-recording a
/// day overwrites it rather than stacking up entries.
class SetHabitLog implements UseCase<Unit, SetHabitLogParams> {
  final HabitRepository repository;

  const SetHabitLog(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SetHabitLogParams params) {
    if (params.date.isAfter(DateTime.now())) {
      return Future.value(
        const Left(
          ValidationFailure(
            'You cannot log a day that has not happened yet.',
            code: FailureCode.futureDay,
          ),
        ),
      );
    }

    final note = params.note?.trim();

    return repository.setLog(
      habitId: params.habitId,
      date: params.date,
      status: params.status,
      note: note == null || note.isEmpty ? null : note,
    );
  }
}
