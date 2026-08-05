import 'habit.dart';

/// Row model for the archived list.
///
/// Carries [logCount] because deleting an archived habit destroys its history
/// too, and the confirmation has to say exactly how much is going rather than
/// warn in the abstract.
class ArchivedHabit {
  final Habit habit;
  final int logCount;

  const ArchivedHabit({required this.habit, required this.logCount});

  bool get hasHistory => logCount > 0;
}
