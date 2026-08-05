import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain_exports.dart';
import 'animated_progress_bar.dart';
import 'time_of_day_pill.dart';

class HabitHeaderCard extends StatelessWidget {
  const HabitHeaderCard({
    super.key,
    required this.habit,
    required this.stats,
    required this.color,
  });

  final Habit habit;
  final HabitStats stats;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TimeOfDayPill(timeOfDay: habit.timeOfDay),
              const Spacer(),
              Flexible(
                child: Text(
                  l10n.sinceDate(l10n.shortDate(habit.startDate)),
                  textAlign: TextAlign.end,
                  style: text.bodyLarge?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (habit.targetNote != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      habit.targetNote!,
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              // The completion figure is the headline of this screen, so it
              // carries the largest type in the app.
              Text('${stats.completionPercent}%', style: text.displayLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedProgressBar(value: stats.completionRate, color: color),
        ],
      ),
    );
  }
}
