import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final Widget icon;

  /// Defaults to the palette accent — resolved in [build] because the
  /// palette is not available to a const default.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          IconTheme(
            data: IconThemeData(color: iconColor ?? palette.accent, size: 22),
            child: icon,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: text.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
