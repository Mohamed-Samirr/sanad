part of 'habit_detail_cubit.dart';

enum HabitDetailStatus { initial, loading, success, failure, deleted }

class HabitDetailState {
  final HabitDetailStatus status;
  final Habit? habit;
  final HabitStats? stats;
  final Map<String, HabitLog> logsByDay;
  final DateTime focusedMonth;
  final String? errorMessage;

  HabitDetailState({
    this.status = HabitDetailStatus.initial,
    this.habit,
    this.stats,
    this.logsByDay = const {},
    DateTime? focusedMonth,
    this.errorMessage,
  }) : focusedMonth = focusedMonth ?? AppDateUtils.startOfMonth(DateTime.now());

  HabitDetailState copyWith({
    HabitDetailStatus? status,
    Habit? habit,
    HabitStats? stats,
    Map<String, HabitLog>? logsByDay,
    DateTime? focusedMonth,
    String? errorMessage,
  }) {
    return HabitDetailState(
      status: status ?? this.status,
      habit: habit ?? this.habit,
      stats: stats ?? this.stats,
      logsByDay: logsByDay ?? this.logsByDay,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      errorMessage: errorMessage,
    );
  }
}
