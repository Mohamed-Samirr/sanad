import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../services/habit_reminder_scheduler.dart';

/// Asks the OS whether this app may show reminders.
///
/// Called the first time a user actually sets a reminder time — the prompt
/// then has an obvious reason attached to it, rather than arriving cold on
/// first launch before the app has earned it.
class RequestReminderPermission implements UseCase<bool, NoParams> {
  final HabitReminderScheduler scheduler;

  const RequestReminderPermission(this.scheduler);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      return Right(await scheduler.ensurePermission());
    } catch (_) {
      return const Left(
        UnexpectedFailure(
          'Could not reach the notification settings.',
          FailureCode.reminderPermissionUnavailable,
        ),
      );
    }
  }
}
