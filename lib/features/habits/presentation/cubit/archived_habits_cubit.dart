import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_archived_habits.dart';
import '../../domain/usecases/restore_habit.dart';
import '../../domain_exports.dart';

part 'archived_habits_state.dart';

class ArchivedHabitsCubit extends Cubit<ArchivedHabitsState> {
  final GetArchivedHabits getArchivedHabits;
  final RestoreHabit restoreHabit;
  final DeleteHabit deleteHabit;
  final HabitRepository repository;

  StreamSubscription<void>? _changesSub;

  ArchivedHabitsCubit({
    required this.getArchivedHabits,
    required this.restoreHabit,
    required this.deleteHabit,
    required this.repository,
  }) : super(const ArchivedHabitsState());

  Future<void> load({bool showLoader = true}) async {
    if (showLoader) {
      emit(state.copyWith(status: ArchivedHabitsStatus.loading));
    }

    final result = await getArchivedHabits(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: ArchivedHabitsStatus.failure,
        failure: failure,
      )),
      (habits) => emit(state.copyWith(
        status: ArchivedHabitsStatus.success,
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

  Future<void> restore(ArchivedHabit entry) async {
    final result = await restoreHabit(entry.habit.id);

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: ArchivedHabitsStatus.success,
        failure: failure,
      )),
      (_) async {
        await load(showLoader: false);
        emit(state.copyWith(
          lastAction: ArchivedAction.restored,
          lastActionHabitName: entry.habit.name,
        ));
      },
    );
  }

  /// Permanent. The data source removes every log keyed to this habit along
  /// with the habit itself, which is why the UI asks twice before calling it.
  Future<void> deletePermanently(ArchivedHabit entry) async {
    final result = await deleteHabit(entry.habit.id);

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: ArchivedHabitsStatus.success,
        failure: failure,
      )),
      (_) async {
        await load(showLoader: false);
        emit(state.copyWith(
          lastAction: ArchivedAction.deleted,
          lastActionHabitName: entry.habit.name,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _changesSub?.cancel();
    return super.close();
  }
}
