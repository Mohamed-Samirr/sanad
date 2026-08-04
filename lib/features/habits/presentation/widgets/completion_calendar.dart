import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain_exports.dart';

/// Month grid of done / missed days. Tapping a past day logs or clears it.
class CompletionCalendar extends StatelessWidget {
  const CompletionCalendar({
    super.key,
    required this.focusedMonth,
    required this.logsByDay,
    required this.habit,
    required this.color,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDayTap,
    this.firstWeekday = DateTime.monday,
  });

  final DateTime focusedMonth;
  final Map<String, HabitLog> logsByDay;
  final Habit habit;
  final Color color;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDayTap;
  final int firstWeekday;

  static const List<String> _weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    final today = AppDateUtils.startOfDay(DateTime.now());
    final firstOfMonth = AppDateUtils.startOfMonth(focusedMonth);
    final dayCount = AppDateUtils.daysInMonth(focusedMonth);
    final leadingBlanks = (firstOfMonth.weekday - firstWeekday + 7) % 7;
    final canGoForward = focusedMonth.isBefore(
      AppDateUtils.startOfMonth(today),
    );

    final orderedLabels = [
      for (var i = 0; i < 7; i++) _weekdayLabels[(firstWeekday - 1 + i) % 7],
    ];

    return Column(
      children: [
        Row(
          children: [
            _NavButton(
              icon: Icons.chevron_left_rounded,
              tooltip: 'Previous month',
              onTap: onPreviousMonth,
            ),
            Expanded(
              child: Text(
                AppDateUtils.monthTitle(focusedMonth),
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
            ),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              tooltip: 'Next month',
              onTap: canGoForward ? onNextMonth : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            for (final label in orderedLabels)
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + dayCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();

            final day = DateTime(
              focusedMonth.year,
              focusedMonth.month,
              index - leadingBlanks + 1,
            );
            final log = logsByDay[AppDateUtils.dayKey(day)];
            final isFuture = day.isAfter(today);

            return _DayCell(
              date: day,
              isDone: log?.isDone ?? false,
              isSkipped: log?.status == HabitLogStatus.skipped,
              isFuture: isFuture,
              isToday: AppDateUtils.isSameDay(day, today),
              isScheduled: habit.isScheduledOn(day),
              color: color,
              onTap: isFuture ? null : () => onDayTap(day),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: palette.habitFill(color), label: 'Done'),
            const SizedBox(width: AppSpacing.xl),
            _LegendDot(color: palette.surfaceAlt, label: 'Missed'),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isDone,
    required this.isSkipped,
    required this.isFuture,
    required this.isToday,
    required this.isScheduled,
    required this.color,
    required this.onTap,
  });

  final DateTime date;
  final bool isDone;
  final bool isSkipped;
  final bool isFuture;
  final bool isToday;
  final bool isScheduled;
  final Color color;
  final VoidCallback? onTap;

  /// A skipped day is a deliberate, neutral choice — it is never coloured or
  /// worded like a miss.
  String get _stateLabel {
    if (isDone) return 'done';
    if (isSkipped) return 'skipped';
    if (isFuture) return 'upcoming';
    if (!isScheduled) return 'not scheduled';
    return 'missed';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    final Color background;
    final Color textColor;

    if (isDone) {
      background = palette.habitFill(color);
      textColor = palette.onHabitFill;
    } else if (isFuture || !isScheduled || isSkipped) {
      background = Colors.transparent;
      textColor = palette.textMuted;
    } else {
      background = palette.surfaceAlt;
      textColor = palette.textSecondary;
    }

    return Semantics(
      button: onTap != null,
      label: '${AppDateUtils.shortDate(date)}, $_stateLabel',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: isToday && !isDone
                ? Border.all(color: palette.accent, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: text.titleSmall?.copyWith(
              color: textColor,
              fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      tooltip: tooltip,
      color: palette.textSecondary,
      disabledColor: palette.textMuted,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}
