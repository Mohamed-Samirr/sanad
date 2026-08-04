import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/get_habit_summaries.dart';
import '../../domain/usecases/toggle_habit_log.dart';
import '../../domain_exports.dart';

part 'habits_state.dart';

class HabitsCubit extends Cubit<HabitsState> {
  final GetHabitSummaries getHabitSummaries;
  final ToggleHabitLog toggleHabitLog;
  final HabitRepository repository;

  StreamSubscription<void>? _changesSub;

  HabitsCubit({
    required this.getHabitSummaries,
    required this.toggleHabitLog,
    required this.repository,
  }) : super(const HabitsState());

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) emit(state.copyWith(status: HabitsStatus.loading));

    final result = await getHabitSummaries(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitsStatus.failure,
        errorMessage: failure.message,
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
        errorMessage: failure.message,
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
