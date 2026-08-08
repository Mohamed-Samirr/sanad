import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/urge_entry.dart';
import '../../domain/usecases/clear_active_urge.dart';
import '../../domain/usecases/get_active_urge.dart';
import '../../domain/usecases/get_behaviors.dart';
import '../../domain/usecases/save_urge.dart';
import 'urge_flow_state.dart';

class UrgeFlowCubit extends Cubit<UrgeFlowState> {
  final GetActiveUrge getActiveUrge;
  final SaveUrge saveUrge;
  final ClearActiveUrge clearActiveUrge;
  final GetBehaviors getBehaviors;

  UrgeFlowCubit({
    required this.getActiveUrge,
    required this.saveUrge,
    required this.clearActiveUrge,
    required this.getBehaviors,
  }) : super(const UrgeFlowState());

  Future<void> initializeFlow() async {
    emit(state.copyWith(status: UrgeFlowStatus.loading, clearError: true));

    // Load active urge if any, else start new
    final activeResult = await getActiveUrge(const NoParams());
    final behaviorsResult = await getBehaviors(const NoParams());

    behaviorsResult.fold(
      (f) => emit(state.copyWith(
          status: UrgeFlowStatus.failure, errorMessage: f.message)),
      (behaviors) {
        activeResult.fold(
          (f) => emit(state.copyWith(
              status: UrgeFlowStatus.failure, errorMessage: f.message)),
          (activeUrge) {
            if (activeUrge != null) {
              // Restore flow state based on what's missing
              UrgeFlowStatus nextStatus = UrgeFlowStatus.logging;
              if (activeUrge.intensity > 0 && activeUrge.chosenStrategy != UrgeStrategy.none) {
                nextStatus = UrgeFlowStatus.outcome;
              } else if (activeUrge.intensity > 0) {
                nextStatus = UrgeFlowStatus.strategizing;
              }

              final selectedBehavior = behaviors.isNotEmpty
                  ? behaviors.firstWhere((b) => b.id == activeUrge.behaviorId,
                      orElse: () => behaviors.first)
                  : null;

              emit(state.copyWith(
                status: nextStatus,
                activeUrge: activeUrge,
                behaviors: behaviors,
                selectedBehavior: selectedBehavior,
              ));
            } else {
              // Create new empty urge if at least one behavior exists
              if (behaviors.isEmpty) {
                emit(state.copyWith(
                    status: UrgeFlowStatus.failure,
                    errorMessage: "No behaviors defined. Please add one first."));
              } else {
                final selectedBehavior = behaviors.first;
                final newUrge = UrgeEntry(
                  id: const Uuid().v4(),
                  behaviorId: selectedBehavior.id,
                  timestamp: DateTime.now(),
                  intensity: 5, // Default mid intensity
                  triggers: const [],
                  feelings: const [],
                );
                
                emit(state.copyWith(
                  status: UrgeFlowStatus.logging,
                  activeUrge: newUrge,
                  behaviors: behaviors,
                  selectedBehavior: selectedBehavior,
                ));
              }
            }
          },
        );
      },
    );
  }

  void updateIntensity(int intensity) {
    if (state.activeUrge != null) {
      emit(state.copyWith(
          activeUrge: state.activeUrge!.copyWith(intensity: intensity)));
    }
  }

  void toggleTrigger(String triggerId) {
    if (state.activeUrge != null) {
      final current = List<String>.from(state.activeUrge!.triggers);
      if (current.contains(triggerId)) {
        current.remove(triggerId);
      } else {
        current.add(triggerId);
      }
      emit(state.copyWith(
          activeUrge: state.activeUrge!.copyWith(triggers: current)));
    }
  }

  void toggleFeeling(String feeling) {
    if (state.activeUrge != null) {
      final current = List<String>.from(state.activeUrge!.feelings);
      if (current.contains(feeling)) {
        current.remove(feeling);
      } else {
        current.add(feeling);
      }
      emit(state.copyWith(
          activeUrge: state.activeUrge!.copyWith(feelings: current)));
    }
  }

  void updateNote(String note) {
    if (state.activeUrge != null) {
      emit(state.copyWith(activeUrge: state.activeUrge!.copyWith(note: note)));
    }
  }

  Future<void> submitLogStep() async {
    if (state.activeUrge != null) {
      emit(state.copyWith(status: UrgeFlowStatus.loading));
      final result = await saveUrge(state.activeUrge!);
      result.fold(
        (f) => emit(state.copyWith(
            status: UrgeFlowStatus.failure, errorMessage: f.message)),
        (_) => emit(state.copyWith(status: UrgeFlowStatus.strategizing)),
      );
    }
  }

  Future<void> chooseStrategy(UrgeStrategy strategy, {String? toolActionId, int? delayDurationSec}) async {
    if (state.activeUrge != null) {
      final updated = state.activeUrge!.copyWith(
        chosenStrategy: strategy,
        toolActionId: toolActionId,
        delayDurationSec: delayDurationSec,
      );
      emit(state.copyWith(activeUrge: updated, status: UrgeFlowStatus.loading));
      final result = await saveUrge(updated);
      result.fold(
        (f) => emit(state.copyWith(
            status: UrgeFlowStatus.failure, errorMessage: f.message)),
        (_) => emit(state.copyWith(status: UrgeFlowStatus.outcome)),
      );
    }
  }

  Future<void> submitOutcome(UrgeOutcome outcome, {String? reflectionNote}) async {
    if (state.activeUrge != null) {
      final updated = state.activeUrge!.copyWith(
        outcome: outcome,
        outcomeAt: DateTime.now(),
        reflectionNote: reflectionNote,
      );
      emit(state.copyWith(activeUrge: updated, status: UrgeFlowStatus.loading));
      final result = await saveUrge(updated);
      result.fold(
        (f) => emit(state.copyWith(
            status: UrgeFlowStatus.failure, errorMessage: f.message)),
        (_) => emit(state.copyWith(status: UrgeFlowStatus.success)),
      );
    }
  }

  Future<void> cancelFlow() async {
    await clearActiveUrge(const NoParams());
    emit(state.copyWith(status: UrgeFlowStatus.initial, activeUrge: null));
  }
}
