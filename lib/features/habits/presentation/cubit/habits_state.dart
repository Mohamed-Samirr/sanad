part of 'habits_cubit.dart';

enum HabitsStatus { initial, loading, success, failure }

class HabitsState {
  final HabitsStatus status;
  final List<HabitSummary> habits;
  final String? errorMessage;

  const HabitsState({
    this.status = HabitsStatus.initial,
    this.habits = const [],
    this.errorMessage,
  });

  List<HabitSummary> byTimeOfDay(HabitTimeOfDay slot) =>
      habits.where((s) => s.habit.timeOfDay == slot).toList();

  int get dueToday => habits.where((s) => s.isScheduledToday).length;

  int get doneToday =>
      habits.where((s) => s.isScheduledToday && s.isDoneToday).length;

  HabitsState copyWith({
    HabitsStatus? status,
    List<HabitSummary>? habits,
    String? errorMessage,
  }) {
    return HabitsState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      errorMessage: errorMessage,
    );
  }
}
