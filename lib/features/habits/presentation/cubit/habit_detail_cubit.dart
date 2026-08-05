import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/clear_habit_log.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_habit_detail.dart';
import '../../domain/usecases/set_habit_log.dart';
import '../../domain_exports.dart';

part 'habit_detail_state.dart';

class HabitDetailCubit extends Cubit<HabitDetailState> {
  final String habitId;
  final GetHabitDetail getHabitDetail;
  final SetHabitLog setHabitLog;
  final ClearHabitLog clearHabitLog;
  final DeleteHabit deleteHabit;
  final ArchiveHabit archiveHabit;
  final HabitRepository repository;

  StreamSubscription<void>? _changesSub;

  HabitDetailCubit({
    required this.habitId,
    required this.getHabitDetail,
    required this.setHabitLog,
    required this.clearHabitLog,
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
        failure: failure,
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

  /// Records a deliberate outcome for [date], with an optional note.
  Future<void> setDay(
    DateTime date, {
    required HabitLogStatus status,
    String? note,
  }) async {
    final result = await setHabitLog(
      SetHabitLogParams(
        habitId: habitId,
        date: date,
        status: status,
        note: note,
      ),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitDetailStatus.success,
        failure: failure,
      )),
      (_) => load(showLoader: false),
    );
  }

  /// Returns [date] to having no entry at all.
  Future<void> clearDay(DateTime date) async {
    final result = await clearHabitLog(
      ClearHabitLogParams(habitId: habitId, date: date),
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitDetailStatus.success,
        failure: failure,
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
        failure: failure,
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
