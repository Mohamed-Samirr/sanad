import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/request_reminder_permission.dart';
import '../../domain/usecases/save_habit.dart';
import '../../domain_exports.dart';

part 'habit_form_state.dart';

/// Create and edit.
///
/// Editing rebuilds the habit rather than using `copyWith`, because
/// `copyWith` cannot distinguish "leave this alone" from "clear this" for
/// `targetNote` — a user who empties the field would silently keep the old
/// one. Rebuilding means every field carried over from the original has to
/// be carried deliberately, which is why [_initial] is kept around.
class HabitFormCubit extends Cubit<HabitFormState> {
  final SaveHabit saveHabit;
  final RequestReminderPermission requestReminderPermission;

  /// The habit being edited, or null when creating.
  final Habit? _initial;

  HabitFormCubit({
    required this.saveHabit,
    required this.requestReminderPermission,
    Habit? initial,
  })  : _initial = initial,
        super(
          initial == null
              ? HabitFormState(
                  startDate: AppDateUtils.startOfDay(DateTime.now()),
                )
              : HabitFormState(
                  id: initial.id,
                  name: initial.name,
                  iconCodePoint: initial.iconCodePoint,
                  colorHex: initial.colorHex,
                  timeOfDay: initial.timeOfDay,
                  scheduleType: initial.scheduleType,
                  scheduledWeekdays: List<int>.from(initial.scheduledWeekdays),
                  timesPerWeek: initial.timesPerWeek ?? 3,
                  targetNote: initial.targetNote ?? '',
                  reminderMinutes: initial.reminderMinutes,
                  startDate: AppDateUtils.startOfDay(initial.startDate),
                ),
        );

  void setName(String value) => emit(state.copyWith(name: value));

  void setIcon(int codePoint) => emit(state.copyWith(iconCodePoint: codePoint));

  void setColor(String hex) => emit(state.copyWith(colorHex: hex));

  void setTimeOfDay(HabitTimeOfDay value) =>
      emit(state.copyWith(timeOfDay: value));

  void setScheduleType(HabitScheduleType value) =>
      emit(state.copyWith(scheduleType: value));

  /// 1 = Monday … 7 = Sunday.
  void toggleWeekday(int weekday) {
    final next = List<int>.from(state.scheduledWeekdays);
    if (!next.remove(weekday)) next.add(weekday);
    next.sort();
    emit(state.copyWith(scheduledWeekdays: next));
  }

  void setTimesPerWeek(int value) =>
      emit(state.copyWith(timesPerWeek: value.clamp(1, 7)));

  void setTargetNote(String value) => emit(state.copyWith(targetNote: value));

  /// Setting a time is the moment the permission prompt has an obvious reason
  /// attached to it, so that is when it is asked for — not at launch.
  ///
  /// If the user declines, the reminder is not kept: a stored time that can
  /// never fire would be a promise the app cannot keep.
  Future<void> setReminder(TimeOfDay? time) async {
    if (time == null) {
      emit(state.copyWith(clearReminder: true));
      return;
    }

    final result = await requestReminderPermission(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        clearReminder: true,
        failure: failure,
      )),
      (granted) {
        if (!granted) {
          emit(state.copyWith(
            clearReminder: true,
            failure: const ValidationFailure(
              'Reminders need notification permission.',
              code: FailureCode.reminderPermissionDenied,
            ),
          ));
          return;
        }
        emit(state.copyWith(reminderMinutes: time.hour * 60 + time.minute));
      },
    );
  }

  /// A habit cannot begin in the future — there would be nothing to log.
  void setStartDate(DateTime date) {
    final today = AppDateUtils.startOfDay(DateTime.now());
    final normalised = AppDateUtils.startOfDay(date);
    emit(state.copyWith(
      startDate: normalised.isAfter(today) ? today : normalised,
    ));
  }

  Future<void> submit() async {
    if (state.isSaving) return;

    // Mirrors SaveHabit's rules so the message lands beside the field that
    // caused it. SaveHabit stays the authority — see the fallback below.
    final nameErrorCode =
        state.name.trim().isEmpty ? FailureCode.nameRequired : null;

    String? scheduleErrorCode;
    if (state.scheduleType == HabitScheduleType.weekdays &&
        state.scheduledWeekdays.isEmpty) {
      scheduleErrorCode = FailureCode.weekdayRequired;
    } else if (state.scheduleType == HabitScheduleType.timesPerWeek &&
        (state.timesPerWeek < 1 || state.timesPerWeek > 7)) {
      scheduleErrorCode = FailureCode.weeklyTargetRange;
    }

    if (nameErrorCode != null || scheduleErrorCode != null) {
      emit(state.copyWith(
        status: HabitFormStatus.editing,
        nameErrorCode: nameErrorCode,
        scheduleErrorCode: scheduleErrorCode,
      ));
      return;
    }

    emit(state.copyWith(status: HabitFormStatus.saving));

    final result = await saveHabit(_buildHabit());

    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitFormStatus.failure,
        // A ValidationFailure here means the local mirror missed a rule, so
        // it is surfaced whole rather than guessed onto a field.
        failure: failure,
      )),
      (_) => emit(state.copyWith(status: HabitFormStatus.saved)),
    );
  }

  Habit _buildHabit() {
    final note = state.targetNote.trim();

    return Habit(
      // Editing keeps the id, so the logs keyed `habitId_yyyy-MM-dd` stay
      // attached and no history is orphaned.
      id: state.id ?? const Uuid().v4(),
      name: state.name.trim(),
      iconCodePoint: state.iconCodePoint,
      colorHex: state.colorHex,
      timeOfDay: state.timeOfDay,
      scheduleType: state.scheduleType,
      // Only the fields the chosen schedule actually uses are written, so a
      // habit switched from weekdays to daily does not keep stale days.
      // Past logs are untouched either way: the schedule is read at scoring
      // time, never baked into the stored log.
      scheduledWeekdays: state.scheduleType == HabitScheduleType.weekdays
          ? List<int>.unmodifiable(state.scheduledWeekdays)
          : const [],
      timesPerWeek: state.scheduleType == HabitScheduleType.timesPerWeek
          ? state.timesPerWeek
          : null,
      targetNote: note.isEmpty ? null : note,
      reminderMinutes: state.reminderMinutes,
      startDate: state.startDate,
      // Carried from the original: rebuilding the habit means anything not
      // on this form would otherwise be silently dropped.
      isArchived: _initial?.isArchived ?? false,
      linkedToolActionId: _initial?.linkedToolActionId,
    );
  }
}
