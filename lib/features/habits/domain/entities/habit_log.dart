import '../../../../core/utils/date_utils.dart';

/// Only positive intent is stored. A scheduled day with no log is a miss,
/// computed at read time — that keeps the box small and makes back-filling
/// old days a single write.
enum HabitLogStatus { done, skipped }

class HabitLog {
  final String habitId;
  final DateTime date;
  final HabitLogStatus status;
  final String? note;
  final DateTime loggedAt;

  const HabitLog({
    required this.habitId,
    required this.date,
    required this.status,
    required this.loggedAt,
    this.note,
  });

  /// Storage key — makes logging idempotent.
  String get id => buildId(habitId, date);

  static String buildId(String habitId, DateTime date) =>
      '${habitId}_${AppDateUtils.dayKey(date)}';

  bool get isDone => status == HabitLogStatus.done;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HabitLog && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
