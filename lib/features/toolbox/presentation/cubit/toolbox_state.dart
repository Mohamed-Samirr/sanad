import 'package:equatable/equatable.dart';

import '../../domain/entities/tool_action.dart';

enum ToolboxStatus { initial, loading, success, failure }

class ToolboxState extends Equatable {
  const ToolboxState({
    this.status = ToolboxStatus.initial,
    this.actions = const [],
    this.errorMessage,
  });

  final ToolboxStatus status;
  final List<ToolAction> actions;
  final String? errorMessage;

  ToolboxState copyWith({
    ToolboxStatus? status,
    List<ToolAction>? actions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ToolboxState(
      status: status ?? this.status,
      actions: actions ?? this.actions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, actions, errorMessage];
}
