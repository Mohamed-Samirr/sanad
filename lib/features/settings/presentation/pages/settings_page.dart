import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../habits/habits_routes.dart';

/// The settings shell.
///
/// Only the parts that have something to manage exist so far. Theme, locale,
/// reminders, the app lock and data export arrive with their own tasks rather
/// than sitting here as dead switches.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          SectionCard(
            title: l10n.settingsHabitsSection,
            icon: Icons.checklist_rounded,
            child: _SettingsRow(
              icon: Icons.inventory_2_outlined,
              label: l10n.settingsArchivedLabel,
              description: l10n.settingsArchivedDescription,
              onTap: () =>
                  Navigator.of(context).pushNamed(HabitsRoutes.archived),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _Disclaimer(),
        ],
      ),
    );
  }
}

/// Required in Settings as well as on first launch. Plain, short, and not
/// alarming — it states what the app is and when to look for more than an app.
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SectionCard(
      title: l10n.settingsAboutSection,
      icon: Icons.info_outline_rounded,
      child: Text(
        l10n.disclaimer,
        style: text.bodyMedium?.copyWith(color: palette.textSecondary),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: palette.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
