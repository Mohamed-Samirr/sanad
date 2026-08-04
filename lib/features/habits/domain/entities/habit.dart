import '../../../../core/utils/date_utils.dart';

enum HabitTimeOfDay { morning, afternoon, evening, anytime }

enum HabitScheduleType { daily, weekdays, timesPerWeek }

class Habit {
  final String id;
  final String name;
  final int iconCodePoint;
  final String colorHex;
  final HabitTimeOfDay timeOfDay;
  final HabitScheduleType scheduleType;

  /// 1 = Monday … 7 = Sunday. Only used for [HabitScheduleType.weekdays].
  final List<int> scheduledWeekdays;

  /// Only used for [HabitScheduleType.timesPerWeek].
  final int? timesPerWeek;

  final String? targetNote;

  /// Minutes since midnight, null when no reminder is set.
  final int? reminderMinutes;

  final DateTime startDate;
  final bool isArchived;

  /// Set when the habit was promoted from a toolbox action.
  final String? linkedToolActionId;

  const Habit({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorHex,
    required this.timeOfDay,
    required this.scheduleType,
    required this.startDate,
    this.scheduledWeekdays = const [],
    this.timesPerWeek,
    this.targetNote,
    this.reminderMinutes,
    this.isArchived = false,
    this.linkedToolActionId,
  });

  /// Whether the habit is expected on [date].
  /// A `timesPerWeek` habit has no fixed days, so every day is eligible —
  /// whether a miss actually costs anything is decided by the score
  /// calculator, which knows how much of the weekly quota is still open.
  bool isScheduledOn(DateTime date) {
    final day = AppDateUtils.startOfDay(date);
    if (day.isBefore(AppDateUtils.startOfDay(startDate))) return false;
    switch (scheduleType) {
      case HabitScheduleType.daily:
        return true;
      case HabitScheduleType.weekdays:
        return scheduledWeekdays.contains(day.weekday);
      case HabitScheduleType.timesPerWeek:
        return true;
    }
  }

  Habit copyWith({
    String? name,
    int? iconCodePoint,
    String? colorHex,
    HabitTimeOfDay? timeOfDay,
    HabitScheduleType? scheduleType,
    List<int>? scheduledWeekdays,
    int? timesPerWeek,
    String? targetNote,
    int? reminderMinutes,
    DateTime? startDate,
    bool? isArchived,
    String? linkedToolActionId,
    bool clearReminder = false,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorHex: colorHex ?? this.colorHex,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduledWeekdays: scheduledWeekdays ?? this.scheduledWeekdays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      targetNote: targetNote ?? this.targetNote,
      reminderMinutes:
          clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      startDate: startDate ?? this.startDate,
      isArchived: isArchived ?? this.isArchived,
      linkedToolActionId: linkedToolActionId ?? this.linkedToolActionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Habit && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
