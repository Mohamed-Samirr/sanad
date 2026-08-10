import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain_exports.dart';
import '../cubit/habit_form_cubit.dart';
import '../widgets/habit_icon.dart';
import '../widgets/time_of_day_pill.dart';

class HabitFormPage extends StatefulWidget {
  const HabitFormPage({super.key});

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // Seeded once from the cubit; afterwards the controllers are the source
    // of truth for their own text and push changes down.
    final state = context.read<HabitFormCubit>().state;
    _nameController = TextEditingController(text: state.name);
    _noteController = TextEditingController(text: state.targetNote);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Inline field errors travel as codes, so the sentence is chosen here.
  static String? _errorText(BuildContext context, String? code) {
    if (code == null) return null;
    return context.l10n.forFailure(ValidationFailure('', code: code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitFormCubit, HabitFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.failure != current.failure,
      listener: (context, state) {
        if (state.status == HabitFormStatus.saved) {
          Navigator.of(context).pop(true);
          return;
        }
        final failure = state.failure;
        if (failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(context.l10n.forFailure(failure))),
            );
        }
      },
      builder: (context, state) {
        final cubit = context.read<HabitFormCubit>();
        final l10n = context.l10n;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              state.isEditing ? l10n.editHabitTitle : l10n.newHabitTitle,
            ),
            actions: [
              TextButton(
                onPressed: state.isSaving ? null : cubit.submit,
                child: Text(state.isSaving ? l10n.saving : l10n.save),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _NameField(
                controller: _nameController,
                errorText: _errorText(context, state.nameErrorCode),
                onChanged: cubit.setName,
              ),
              const SizedBox(height: AppSpacing.lg),
              _AppearanceSection(
                iconCodePoint: state.iconCodePoint,
                colorHex: state.colorHex,
                onIconSelected: cubit.setIcon,
                onColorSelected: cubit.setColor,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ScheduleSection(
                scheduleType: state.scheduleType,
                scheduledWeekdays: state.scheduledWeekdays,
                timesPerWeek: state.timesPerWeek,
                errorText: _errorText(context, state.scheduleErrorCode),
                onTypeChanged: cubit.setScheduleType,
                onWeekdayToggled: cubit.toggleWeekday,
                onTimesPerWeekChanged: cubit.setTimesPerWeek,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TimeOfDaySection(
                selected: state.timeOfDay,
                onChanged: cubit.setTimeOfDay,
              ),
              const SizedBox(height: AppSpacing.lg),
              _DetailsSection(
                noteController: _noteController,
                onNoteChanged: cubit.setTargetNote,
                reminderMinutes: state.reminderMinutes,
                onReminderChanged: cubit.setReminder,
                startDate: state.startDate,
                isEditing: state.isEditing,
                onStartDateChanged: cubit.setStartDate,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: state.isSaving ? null : cubit.submit,
                child: Text(
                  state.isEditing ? l10n.saveChanges : l10n.startTracking,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SectionCard(
      title: l10n.formNameSection,
      icon: Icons.edit_outlined,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.formNameHint,
          errorText: errorText,
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({
    required this.iconCodePoint,
    required this.colorHex,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  final int iconCodePoint;
  final String colorHex;
  final ValueChanged<int> onIconSelected;
  final ValueChanged<String> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final selected = AppColors.fromHex(colorHex);

    return SectionCard(
      title: l10n.formAppearanceSection,
      icon: Icons.palette_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final icon in HabitIcons.catalogue)
                _IconChoice(
                  icon: icon,
                  color: selected,
                  isSelected: icon.codePoint == iconCodePoint,
                  onTap: () => onIconSelected(icon.codePoint),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.formColourLabel,
            style: text.labelMedium?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final hex in AppColors.habitPalette)
                _ColorChoice(
                  hex: hex,
                  isSelected: hex == colorHex,
                  onTap: () => onColorSelected(hex),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.formIconSemantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isSelected ? palette.habitTint(color) : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: isSelected
                ? Border.all(color: palette.habitInk(color), width: 1.5)
                : null,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? palette.habitInk(color) : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.hex,
    required this.isSelected,
    required this.onTap,
  });

  final String hex;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final stored = AppColors.fromHex(hex);

    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.formColourSemantics,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          width: 48,
          child: Center(
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: palette.habitFill(stored),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: palette.textPrimary, width: 3)
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: palette.onHabitFill,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.scheduleType,
    required this.scheduledWeekdays,
    required this.timesPerWeek,
    required this.errorText,
    required this.onTypeChanged,
    required this.onWeekdayToggled,
    required this.onTimesPerWeekChanged,
  });

  final HabitScheduleType scheduleType;
  final List<int> scheduledWeekdays;
  final int timesPerWeek;
  final String? errorText;
  final ValueChanged<HabitScheduleType> onTypeChanged;
  final ValueChanged<int> onWeekdayToggled;
  final ValueChanged<int> onTimesPerWeekChanged;

  Widget _weekdayChip(AppLocalizations l10n, int weekday) => _ChoiceChip(
        label: l10n.weekdayNamesShort[weekday - 1],
        isSelected: scheduledWeekdays.contains(weekday),
        onTap: () => onWeekdayToggled(weekday),
      );

  static String _labelFor(AppLocalizations l10n, HabitScheduleType type) {
    switch (type) {
      case HabitScheduleType.daily:
        return l10n.scheduleDaily;
      case HabitScheduleType.weekdays:
        return l10n.scheduleWeekdays;
      case HabitScheduleType.timesPerWeek:
        return l10n.scheduleTimesPerWeek;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SectionCard(
      title: l10n.formScheduleSection,
      icon: Icons.event_repeat_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final type in HabitScheduleType.values)
                _ChoiceChip(
                  label: _labelFor(l10n, type),
                  isSelected: type == scheduleType,
                  onTap: () => onTypeChanged(type),
                ),
            ],
          ),
          if (scheduleType == HabitScheduleType.weekdays) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                // Ordered by the locale's own week start, so the Arabic form
                // opens on Saturday the way the calendar does.
                for (var i = 0; i < 7; i++)
                  _weekdayChip(
                    l10n,
                    ((l10n.firstWeekday - 1 + i) % 7) + 1,
                  ),
              ],
            ),
          ],
          if (scheduleType == HabitScheduleType.timesPerWeek) ...[
            const SizedBox(height: AppSpacing.lg),
            _Stepper(
              value: timesPerWeek,
              min: 1,
              max: 7,
              onChanged: onTimesPerWeekChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.timesPerWeekExplain(timesPerWeek),
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              errorText!,
              style: text.bodySmall?.copyWith(color: palette.caution),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeOfDaySection extends StatelessWidget {
  const _TimeOfDaySection({required this.selected, required this.onChanged});

  final HabitTimeOfDay selected;
  final ValueChanged<HabitTimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.l10n.formTimeOfDaySection,
      icon: Icons.schedule_rounded,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final slot in HabitTimeOfDay.values)
            _ChoiceChip(
              label: TimeOfDayPill.labelFor(context, slot),
              icon: TimeOfDayPill.iconFor(slot),
              isSelected: slot == selected,
              onTap: () => onChanged(slot),
            ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.noteController,
    required this.onNoteChanged,
    required this.reminderMinutes,
    required this.onReminderChanged,
    required this.startDate,
    required this.isEditing,
    required this.onStartDateChanged,
  });

  final TextEditingController noteController;
  final ValueChanged<String> onNoteChanged;
  final int? reminderMinutes;
  final ValueChanged<TimeOfDay?> onReminderChanged;
  final DateTime startDate;
  final bool isEditing;
  final ValueChanged<DateTime> onStartDateChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final reminder = reminderMinutes == null
        ? null
        : TimeOfDay(
            hour: reminderMinutes! ~/ 60,
            minute: reminderMinutes! % 60,
          );

    return SectionCard(
      title: l10n.formDetailsSection,
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: noteController,
            onChanged: onNoteChanged,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.formTargetLabel,
              hintText: l10n.formTargetHint,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Row(
            icon: Icons.notifications_none_rounded,
            label: l10n.formReminderLabel,
            value: reminder == null
                ? l10n.formReminderOff
                : reminder.format(context),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: reminder ?? const TimeOfDay(hour: 8, minute: 0),
              );
              if (picked != null) onReminderChanged(picked);
            },
            trailing: reminder == null
                ? null
                : IconButton(
                    onPressed: () => onReminderChanged(null),
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
          const Divider(height: AppSpacing.xl),
          _Row(
            icon: Icons.play_circle_outline_rounded,
            label: l10n.formStartDateLabel,
            value: l10n.shortDate(startDate),
            // Editing leaves the start date alone: the health curve is rebuilt
            // from this day, so moving it would rewrite history the user
            // already logged.
            onTap: isEditing
                ? null
                : () async {
                    final today = AppDateUtils.startOfDay(DateTime.now());
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(today.year - 5),
                      lastDate: today,
                    );
                    if (picked != null) onStartDateChanged(picked);
                  },
          ),
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.formStartDateLockedNote,
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: palette.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: text.bodyLarge)),
            Text(
              value,
              style: text.bodyLarge?.copyWith(
                color: onTap == null ? palette.textSecondary : palette.accent,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? palette.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: isSelected ? palette.accent : palette.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? palette.onAccent : palette.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: text.titleSmall?.copyWith(
                  color: isSelected ? palette.onAccent : palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Row(
      children: [
        IconButton.outlined(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        Expanded(
          child: Semantics(
            label: '$value ${l10n.daysPerWeekLabel(value)}',
            excludeSemantics: true,
            child: Column(
              children: [
                Text('$value', style: text.displaySmall),
                Text(
                  l10n.daysPerWeekLabel(value),
                  style: text.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
