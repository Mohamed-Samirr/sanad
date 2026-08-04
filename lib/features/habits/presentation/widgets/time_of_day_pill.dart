import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain_exports.dart';

class TimeOfDayPill extends StatelessWidget {
  const TimeOfDayPill({super.key, required this.timeOfDay});

  final HabitTimeOfDay timeOfDay;

  static IconData iconFor(HabitTimeOfDay slot) {
    switch (slot) {
      case HabitTimeOfDay.morning:
        return Icons.wb_twilight_rounded;
      case HabitTimeOfDay.afternoon:
        return Icons.wb_sunny_rounded;
      case HabitTimeOfDay.evening:
        return Icons.nightlight_round;
      case HabitTimeOfDay.anytime:
        return Icons.all_inclusive_rounded;
    }
  }

  static String labelFor(HabitTimeOfDay slot) {
    switch (slot) {
      case HabitTimeOfDay.morning:
        return 'Morning';
      case HabitTimeOfDay.afternoon:
        return 'Afternoon';
      case HabitTimeOfDay.evening:
        return 'Evening';
      case HabitTimeOfDay.anytime:
        return 'Anytime';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(timeOfDay), size: 18, color: palette.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(labelFor(timeOfDay), style: text.titleSmall),
        ],
      ),
    );
  }
}
