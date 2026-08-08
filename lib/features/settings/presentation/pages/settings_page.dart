import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../habits/habits_routes.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// The settings shell.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => previous.error != current.error || previous.isLoading != current.isLoading,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: context.palette.caution),
            );
          }
          // A loading overlay could be handled here or globally
        },
        builder: (context, state) {
          return Stack(
            children: [
              ListView(
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
          SectionCard(
            title: 'Privacy & Data',
            icon: Icons.security_rounded,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'App Lock (PIN & Biometrics)',
                  description: 'Secure your app with a PIN or fingerprint',
                  onTap: () {
                    // TODO: Navigate to App Lock setup
                  },
                ),
                const Divider(),
                _SettingsRow(
                  icon: Icons.upload_file_rounded,
                  label: 'Export Data',
                  description: 'Backup your data to a secure file',
                  onTap: () {
                    context.read<SettingsCubit>().exportData();
                  },
                ),
                const Divider(),
                _SettingsRow(
                  icon: Icons.download_rounded,
                  label: 'Import Data',
                  description: 'Restore your data from a previous backup',
                  onTap: () {
                    context.read<SettingsCubit>().importData();
                  },
                ),
                const Divider(),
                _SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: 'Wipe Data',
                  description: 'Permanently delete all your data',
                  isDestructive: true,
                  onTap: () => _confirmWipeData(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _Disclaimer(),
        ],
      ),
              if (state.isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmWipeData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wipe All Data?'),
        content: const Text('This action is permanent and cannot be undone. Are you absolutely sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Wipe Data', style: TextStyle(color: ctx.palette.caution)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SettingsCubit>().wipeData();
    }
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
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isDestructive;

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
            Icon(icon, size: 20, color: isDestructive ? palette.caution : palette.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.titleSmall?.copyWith(
                    color: isDestructive ? palette.caution : null,
                  )),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: text.bodySmall?.copyWith(
                      color: isDestructive ? palette.caution.withValues(alpha: 0.8) : palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? palette.caution : palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
