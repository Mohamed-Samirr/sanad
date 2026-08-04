import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_habit_detail.dart';
import '../../domain/usecases/toggle_habit_log.dart';
import '../../domain_exports.dart';

part 'habit_detail_state.dart';

class HabitDetailCubit extends Cubit<HabitDetailState> {
  final String habitId;
  final GetHabitDetail getHabitDetail;
  final ToggleHabitLog toggleHabitLog;
  final DeleteHabit deleteHabit;
  final ArchiveHabit archiveHabit;
  final HabitRepository repository;

  StreamSubscription<void>? _changesSub;

  HabitDetailCubit({
    required this.habitId,
    required this.getHabitDetail,
    required this.toggleHabitLog,
    required this.deleteHabit,
    required this.archiveHabit,
    required this.repository,
  }) : super(HabitDetailState());

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      emit(state.copyWith(status: HabitDetailStatus.loading));
    }

    final result = await getHabitDetail(GetHabitDetailParams(habitId));

    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (detail) => emit(state.copyWith(
        status: HabitDetailStatus.success,
        habit: detail.habit,
        stats: detail.stats,
        logsByDay: detail.logsByDay,
      )),
    );
  }

  void listenToChanges() {
    _changesSub?.cancel();
    _changesSub = repository.watchChanges().listen((_) {
      if (state.status != HabitDetailStatus.deleted) {
        load(showLoader: false);
      }
    });
  }

  void showPreviousMonth() => emit(
        state.copyWith(
          focusedMonth:
              DateTime(state.focusedMonth.year, state.focusedMonth.month - 1),
        ),
      );

  void showNextMonth() {
    final next =
        DateTime(state.focusedMonth.year, state.focusedMonth.month + 1);
    final thisMonth = AppDateUtils.startOfMonth(DateTime.now());
    if (next.isAfter(thisMonth)) return;
    emit(state.copyWith(focusedMonth: next));
  }

  /// Log or un-log any past day straight from the calendar.
  Future<void> toggleDay(DateTime date) async {
    final key = AppDateUtils.dayKey(date);
    final isDone = state.logsByDay[key]?.isDone ?? false;

    final result = await toggleHabitLog(
      ToggleHabitLogParams(
        habitId: habitId,
        date: date,
        isCurrentlyDone: isDone,
      ),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitDetailStatus.success,
        errorMessage: failure.message,
      )),
      (_) => load(showLoader: false),
    );
  }

  Future<void> remove({bool archive = false}) async {
    final result =
        archive ? await archiveHabit(habitId) : await deleteHabit(habitId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: HabitDetailStatus.deleted)),
    );
  }

  @override
  Future<void> close() {
    _changesSub?.cancel();
    return super.close();
  }
}
