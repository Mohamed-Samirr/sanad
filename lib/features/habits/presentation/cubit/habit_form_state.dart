part of 'habit_form_cubit.dart';

enum HabitFormStatus { editing, saving, saved, failure }

/// Form state for creating or editing a habit.
///
/// Field errors are separate from [errorMessage]: the first two belong beside
/// the input that caused them, the last is for a failure the user cannot fix
/// inline (storage, mostly). All three clear unless explicitly passed, so a
/// message is shown once and does not stick to the next keystroke.
class HabitFormState {
  final HabitFormStatus status;

  /// Null while creating. Present when editing — carried through untouched so
  /// the habit keeps its identity and its logs.
  final String? id;

  final String name;
  final int iconCodePoint;
  final String colorHex;
  final HabitTimeOfDay timeOfDay;
  final HabitScheduleType scheduleType;
  final List<int> scheduledWeekdays;
  final int timesPerWeek;
  final String targetNote;

  /// Minutes since midnight, null when no reminder is set.
  final int? reminderMinutes;

  final DateTime startDate;

  final String? nameError;
  final String? scheduleError;
  final String? errorMessage;

  const HabitFormState({
    required this.startDate,
    this.status = HabitFormStatus.editing,
    this.id,
    this.name = '',
    this.iconCodePoint = 0xf5ca, // Icons.bolt_rounded
    this.colorHex = 'FFB9A9FF',
    this.timeOfDay = HabitTimeOfDay.anytime,
    this.scheduleType = HabitScheduleType.daily,
    this.scheduledWeekdays = const [],
    this.timesPerWeek = 3,
    this.targetNote = '',
    this.reminderMinutes,
    this.nameError,
    this.scheduleError,
    this.errorMessage,
  });

  bool get isEditing => id != null;

  bool get isSaving => status == HabitFormStatus.saving;

  HabitFormState copyWith({
    HabitFormStatus? status,
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
    String? nameError,
    String? scheduleError,
    String? errorMessage,
    bool clearReminder = false,
  }) {
    return HabitFormState(
      status: status ?? this.status,
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
      nameError: nameError,
      scheduleError: scheduleError,
      errorMessage: errorMessage,
    );
  }
}
