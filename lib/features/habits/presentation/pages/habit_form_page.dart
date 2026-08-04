import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitFormCubit, HabitFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == HabitFormStatus.saved) {
          Navigator.of(context).pop(true);
          return;
        }
        final message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<HabitFormCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEditing ? 'Edit habit' : 'New habit'),
            actions: [
              TextButton(
                onPressed: state.isSaving ? null : cubit.submit,
                child: Text(state.isSaving ? 'Saving…' : 'Save'),
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
                errorText: state.nameError,
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
                errorText: state.scheduleError,
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
                  state.isEditing ? 'Save changes' : 'Start tracking',
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
    return SectionCard(
      title: 'What are you building?',
      icon: Icons.edit_outlined,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Morning walk',
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
    final selected = AppColors.fromHex(colorHex);

    return SectionCard(
      title: 'Icon and colour',
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
            'Colour',
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
      label: 'Habit icon',
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
      label: 'Habit colour',
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

  static const List<String> _weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static String _labelFor(HabitScheduleType type) {
    switch (type) {
      case HabitScheduleType.daily:
        return 'Every day';
      case HabitScheduleType.weekdays:
        return 'Certain days';
      case HabitScheduleType.timesPerWeek:
        return 'Times a week';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return SectionCard(
      title: 'How often?',
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
                  label: _labelFor(type),
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
                for (var weekday = 1; weekday <= 7; weekday++)
                  _ChoiceChip(
                    label: _weekdayLabels[weekday - 1],
                    isSelected: scheduledWeekdays.contains(weekday),
                    onTap: () => onWeekdayToggled(weekday),
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
              'Any $timesPerWeek days that suit you. A day only counts against '
              'you once the week can no longer reach the target.',
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
      title: 'When in the day?',
      icon: Icons.schedule_rounded,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final slot in HabitTimeOfDay.values)
            _ChoiceChip(
              label: TimeOfDayPill.labelFor(slot),
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

    final reminder = reminderMinutes == null
        ? null
        : TimeOfDay(
            hour: reminderMinutes! ~/ 60,
            minute: reminderMinutes! % 60,
          );

    return SectionCard(
      title: 'Details',
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: noteController,
            onChanged: onNoteChanged,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Target (optional)',
              hintText: '30 minutes, 5 pages',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Row(
            icon: Icons.notifications_none_rounded,
            label: 'Reminder',
            value: reminder == null
                ? 'Off'
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
                    tooltip: 'Turn reminder off',
                  ),
          ),
          const Divider(height: AppSpacing.xl),
          _Row(
            icon: Icons.play_circle_outline_rounded,
            label: 'Start date',
            value: AppDateUtils.shortDate(startDate),
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
              'The start date stays put so your logged history keeps its shape.',
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

    return Row(
      children: [
        IconButton.outlined(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
          tooltip: 'Fewer days',
        ),
        Expanded(
          child: Semantics(
            label: '$value times a week',
            excludeSemantics: true,
            child: Column(
              children: [
                Text('$value', style: text.displaySmall),
                Text(
                  value == 1 ? 'day a week' : 'days a week',
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
          tooltip: 'More days',
        ),
      ],
    );
  }
}
