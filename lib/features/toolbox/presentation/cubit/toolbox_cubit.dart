import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/toolbox_repository.dart';
import '../../domain/usecases/get_toolbox_actions.dart';
import 'toolbox_state.dart';

class ToolboxCubit extends Cubit<ToolboxState> {
  ToolboxCubit({
    required this.getToolboxActions,
    required ToolboxRepository repository,
  })  : _repository = repository,
        super(const ToolboxState());

  final GetToolboxActions getToolboxActions;
  final ToolboxRepository _repository;
  StreamSubscription<void>? _subscription;

  Future<void> load() async {
    emit(state.copyWith(status: ToolboxStatus.loading, clearError: true));
    final result = await getToolboxActions(const NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ToolboxStatus.failure,
        errorMessage: failure.message,
      )),
      (actions) => emit(state.copyWith(
        status: ToolboxStatus.success,
        actions: actions,
      )),
    );
  }

  void listenToChanges() {
    _subscription?.cancel();
    _subscription = _repository.watchToolActions().listen((_) => load());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
