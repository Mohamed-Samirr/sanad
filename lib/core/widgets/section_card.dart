import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

/// The single container used for every block on the habit screens.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.title,
    this.icon,
    this.subtitle,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? title;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: palette.accent),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(child: Text(title!, style: text.titleLarge)),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}
