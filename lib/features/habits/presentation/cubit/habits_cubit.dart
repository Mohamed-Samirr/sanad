import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/clear_habit_log.dart';
import '../../domain/usecases/get_habit_summaries.dart';
import '../../domain/usecases/set_habit_log.dart';
import '../../domain/usecases/toggle_habit_log.dart';
import '../../domain_exports.dart';

part 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final GetHabitSummaries getHabitSummaries;
  final ToggleHabitLog toggleHabitLog;
  final SetHabitLog setHabitLog;
  final ClearHabitLog clearHabitLog;
  final HabitRepository repository;

  StreamSubscription<void>? _changesSub;

  HabitsCubit({
    required this.getHabitSummaries,
    required this.toggleHabitLog,
    required this.setHabitLog,
    required this.clearHabitLog,
    required this.repository,
  }) : super(const HabitsState());

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) emit(state.copyWith(status: HabitsStatus.loading));

    final result = await getHabitSummaries(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitsStatus.failure,
        failure: failure,
      )),
      (habits) => emit(state.copyWith(
        status: HabitsStatus.success,
        habits: habits,
      )),
    );
  }

  void listenToChanges() {
    _changesSub?.cancel();
    _changesSub = repository.watchChanges().listen((_) {
      load(showLoader: false);
    });
  }

  Future<void> toggleToday(HabitSummary summary) async {
    final result = await toggleHabitLog(
      ToggleHabitLogParams(
        habitId: summary.habit.id,
        date: DateTime.now(),
        isCurrentlyDone: summary.isDoneToday,
      ),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitsStatus.failure,
        failure: failure,
      )),
      (_) => load(showLoader: false),
    );
  }

  /// Marks today deliberately skipped from the list row's long-press menu.
  /// A skip is a decision, not a lapse — the calculator treats it as neutral
  /// and the streak survives it.
  Future<void> skipToday(HabitSummary summary) async {
    final result = await setHabitLog(
      SetHabitLogParams(
        habitId: summary.habit.id,
        date: DateTime.now(),
        status: HabitLogStatus.skipped,
      ),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitsStatus.failure,
        failure: failure,
      )),
      (_) => load(showLoader: false),
    );
  }

  /// Removes today's entry, whatever it was.
  Future<void> clearToday(HabitSummary summary) async {
    final result = await clearHabitLog(
      ClearHabitLogParams(habitId: summary.habit.id, date: DateTime.now()),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitsStatus.failure,
        failure: failure,
      )),
      (_) => load(showLoader: false),
    );
  }

  @override
  Future<void> close() {
    _changesSub?.cancel();
    return super.close();
  }
}
