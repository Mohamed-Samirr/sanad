part of 'habit_detail_cubit.dart';

enum HabitDetailStatus { initial, loading, success, failure, deleted }

class HabitDetailState {
  final HabitDetailStatus status;
  final Habit? habit;
  final HabitStats? stats;
  final Map<String, HabitLog> logsByDay;
  final DateTime focusedMonth;
  final Failure? failure;

  HabitDetailState({
    this.status = HabitDetailStatus.initial,
    this.habit,
    this.stats,
    this.logsByDay = const {},
    DateTime? focusedMonth,
    this.failure,
  }) : focusedMonth = focusedMonth ?? AppDateUtils.startOfMonth(DateTime.now());

  /// Logged days, newest first. Only days the user actually recorded appear —
  /// misses are absent by design, so this reads as a history of choices made
  /// rather than a ledger of failures.
  List<HabitLog> get recentLogs {
    final logs = logsByDay.values.toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  HabitDetailState copyWith({
    HabitDetailStatus? status,
    Habit? habit,
    HabitStats? stats,
    Map<String, HabitLog>? logsByDay,
    DateTime? focusedMonth,
    Failure? failure,
  }) {
    return HabitDetailState(
      status: status ?? this.status,
      habit: habit ?? this.habit,
      stats: stats ?? this.stats,
      logsByDay: logsByDay ?? this.logsByDay,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      failure: failure,
    );
  }
}
