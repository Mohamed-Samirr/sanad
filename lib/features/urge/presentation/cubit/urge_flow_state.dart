import 'package:equatable/equatable.dart';
import '../../domain/entities/urge_entry.dart';
import '../../domain/entities/behavior.dart';

enum UrgeFlowStatus { initial, loading, logging, strategizing, outcome, success, failure }

class UrgeFlowState extends Equatable {
  final UrgeFlowStatus status;
  final UrgeEntry? activeUrge;
  final Behavior? selectedBehavior;
  final List<Behavior> behaviors;
  final String? errorMessage;

  const UrgeFlowState({
    this.status = UrgeFlowStatus.initial,
    this.activeUrge,
    this.selectedBehavior,
    this.behaviors = const [],
    this.errorMessage,
  });

  UrgeFlowState copyWith({
    UrgeFlowStatus? status,
    UrgeEntry? activeUrge,
    Behavior? selectedBehavior,
    List<Behavior>? behaviors,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UrgeFlowState(
      status: status ?? this.status,
      activeUrge: activeUrge ?? this.activeUrge,
      selectedBehavior: selectedBehavior ?? this.selectedBehavior,
      behaviors: behaviors ?? this.behaviors,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeUrge,
        selectedBehavior,
        behaviors,
        errorMessage,
      ];
}
