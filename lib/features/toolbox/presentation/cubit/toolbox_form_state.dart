import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

enum ToolboxFormStatus { initial, saving, saved, failure }

class ToolboxFormState extends Equatable {
  const ToolboxFormState({
    this.status = ToolboxFormStatus.initial,
    this.id,
    this.title = '',
    this.description = '',
    this.durationMin = 15,
    this.iconCodePoint = 0xe03a, // A default icon
    this.category = 'physical',
    this.failure,
  });

  final ToolboxFormStatus status;
  final String? id; // null if creating
  final String title;
  final String description;
  final int durationMin;
  final int iconCodePoint;
  final String category;
  final Failure? failure;

  bool get isEditing => id != null;
  bool get isSaving => status == ToolboxFormStatus.saving;
  String? get titleErrorCode =>
      failure?.code == FailureCode.nameRequired ? failure!.code : null;

  ToolboxFormState copyWith({
    ToolboxFormStatus? status,
    String? title,
    String? description,
    int? durationMin,
    int? iconCodePoint,
    String? category,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ToolboxFormState(
      status: status ?? this.status,
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMin: durationMin ?? this.durationMin,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      category: category ?? this.category,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        id,
        title,
        description,
        durationMin,
        iconCodePoint,
        category,
        failure,
      ];
}
