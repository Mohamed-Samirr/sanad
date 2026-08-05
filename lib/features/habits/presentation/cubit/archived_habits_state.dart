part of 'archived_habits_cubit.dart';

enum ArchivedHabitsStatus { initial, loading, success, failure }

enum ArchivedAction { restored, deleted }

class ArchivedHabitsState {
  final ArchivedHabitsStatus status;
  final List<ArchivedHabit> habits;
  final Failure? failure;

  /// What just happened, and to which habit, so the screen can confirm it.
  /// The cubit records the fact; the widget writes the sentence, because only
  /// it knows the locale.
  final ArchivedAction? lastAction;
  final String? lastActionHabitName;

  const ArchivedHabitsState({
    this.status = ArchivedHabitsStatus.initial,
    this.habits = const [],
    this.failure,
    this.lastAction,
    this.lastActionHabitName,
  });

  ArchivedHabitsState copyWith({
    ArchivedHabitsStatus? status,
    List<ArchivedHabit>? habits,
    Failure? failure,
    ArchivedAction? lastAction,
    String? lastActionHabitName,
  }) {
    return ArchivedHabitsState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      failure: failure,
      lastAction: lastAction,
      lastActionHabitName: lastActionHabitName,
    );
  }
}
