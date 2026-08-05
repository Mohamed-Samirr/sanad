import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
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
    this.firstWeekday,
  });

  final DateTime focusedMonth;
  final Map<String, HabitLog> logsByDay;
  final Habit habit;
  final Color color;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDayTap;

  /// Defaults to the locale's own week start — Saturday for Arabic, Monday
  /// for English — unless a caller overrides it.
  final int? firstWeekday;

  static bool _isRtl(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final weekStart = firstWeekday ?? l10n.firstWeekday;

    final today = AppDateUtils.startOfDay(DateTime.now());
    final firstOfMonth = AppDateUtils.startOfMonth(focusedMonth);
    final dayCount = AppDateUtils.daysInMonth(focusedMonth);
    final leadingBlanks = (firstOfMonth.weekday - weekStart + 7) % 7;
    final canGoForward = focusedMonth.isBefore(
      AppDateUtils.startOfMonth(today),
    );

    final orderedLabels = [
      for (var i = 0; i < 7; i++)
        l10n.weekdayNamesShort[(weekStart - 1 + i) % 7],
    ];

    return Column(
      children: [
        Row(
          children: [
            _NavButton(
              // "Back in time" points left in English and right in Arabic.
              // These icons do not mirror themselves, so the direction is
              // resolved here rather than assumed.
              icon: _isRtl(context)
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              tooltip: l10n.previousMonth,
              onTap: onPreviousMonth,
            ),
            Expanded(
              child: Text(
                l10n.monthTitle(focusedMonth),
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
            ),
            _NavButton(
              icon: _isRtl(context)
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              tooltip: l10n.nextMonth,
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
            _LegendDot(
              color: palette.habitFill(color),
              label: l10n.legendDone,
            ),
            const SizedBox(width: AppSpacing.lg),
            _LegendDot(
              color: palette.divider,
              label: l10n.legendSkipped,
              outlined: true,
            ),
            const SizedBox(width: AppSpacing.lg),
            _LegendDot(color: palette.surfaceAlt, label: l10n.legendMissed),
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
  String _stateLabel(AppLocalizations l10n) {
    if (isDone) return l10n.dayStateDone;
    if (isSkipped) return l10n.dayStateSkipped;
    if (isFuture) return l10n.dayStateUpcoming;
    if (!isScheduled) return l10n.dayStateNotScheduled;
    return l10n.dayStateMissed;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final Color background;
    final Color textColor;
    Border? border;

    if (isDone) {
      background = palette.habitFill(color);
      textColor = palette.onHabitFill;
    } else if (isSkipped) {
      // A deliberate pause gets its own quiet shape — outlined rather than
      // filled — so it never reads as the same thing as a missed day.
      background = Colors.transparent;
      textColor = palette.textSecondary;
      border = Border.all(color: palette.divider, width: 1.5);
    } else if (isFuture || !isScheduled) {
      background = Colors.transparent;
      textColor = palette.textMuted;
    } else {
      background = palette.surfaceAlt;
      textColor = palette.textSecondary;
    }

    if (isToday && !isDone) {
      border = Border.all(color: palette.accent, width: 1.5);
    }

    return Semantics(
      button: onTap != null,
      label: l10n.dayCellSemantics(l10n.shortDate(date), _stateLabel(l10n)),
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
            border: border,
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
  const _LegendDot({
    required this.color,
    required this.label,
    this.outlined = false,
  });

  final Color color;
  final String label;

  /// Matches the outlined shape a skipped day uses in the grid.
  final bool outlined;

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
            color: outlined ? Colors.transparent : color,
            border: outlined ? Border.all(color: color, width: 1.5) : null,
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
