import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/tool_action.dart';
import '../../domain/usecases/save_tool_action.dart';
import 'toolbox_form_state.dart';

class ToolboxFormCubit extends Cubit<ToolboxFormState> {
  ToolboxFormCubit({
    required this.saveToolAction,
    ToolAction? action,
  }) : super(
          action != null
              ? ToolboxFormState(
                  id: action.id,
                  title: action.title,
                  description: action.description,
                  durationMin: action.durationMin,
                  iconCodePoint: action.iconCode,
                  category: action.category,
                )
              : const ToolboxFormState(),
        );

  final SaveToolAction saveToolAction;

  void setTitle(String value) => emit(state.copyWith(title: value, clearFailure: true));
  void setDescription(String value) => emit(state.copyWith(description: value));
  void setDuration(int value) => emit(state.copyWith(durationMin: value));
  void setIcon(int value) => emit(state.copyWith(iconCodePoint: value));
  void setCategory(String value) => emit(state.copyWith(category: value));

  Future<void> submit(int? existingTimesUsed, int? existingTimesWorked) async {
    emit(state.copyWith(status: ToolboxFormStatus.saving, clearFailure: true));

    final newAction = ToolAction(
      id: state.id ?? const Uuid().v4(),
      title: state.title.trim(),
      description: state.description.trim(),
      durationMin: state.durationMin,
      iconCode: state.iconCodePoint,
      category: state.category,
      timesUsed: existingTimesUsed ?? 0,
      timesWorked: existingTimesWorked ?? 0,
    );

    final result = await saveToolAction(newAction);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ToolboxFormStatus.failure,
        failure: failure,
      )),
      (_) => emit(state.copyWith(status: ToolboxFormStatus.saved)),
    );
  }
}
