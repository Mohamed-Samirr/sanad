import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../settings/settings_routes.dart';
import '../../../urge/domain/entities/support_contact.dart';
import '../cubit/support_cubit.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supportTitle),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(SettingsRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_support_fab',
        onPressed: () => Navigator.of(context).pushNamed('/support-form'),
        tooltip: l10n.addSupportContact,
        child: const Icon(Icons.person_add_rounded),
      ),
      body: BlocBuilder<SupportCubit, SupportState>(
        builder: (context, state) {
          if (state.status == SupportStatus.loading || state.status == SupportStatus.initial) {
            final animate = !MediaQuery.disableAnimationsOf(context);
            return Center(
              child: animate 
                  ? const CircularProgressIndicator() 
                  : const CircularProgressIndicator(value: 0),
            );
          }

          if (state.contacts.isEmpty) {
            return EmptyState(
              icon: Icons.group_outlined,
              title: l10n.noSupportContactsTitle,
              message: l10n.noSupportContactsMessage,
              actionLabel: l10n.addSupportContact,
              onAction: () => Navigator.of(context).pushNamed('/support-form'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            itemCount: state.contacts.length,
            itemBuilder: (context, index) {
              final contact = state.contacts[index];
              return _ContactRow(contact: contact);
            },
          );
        },
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact});
  final SupportContact contact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final cubit = context.read<SupportCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => Navigator.of(context).pushNamed('/support-form', arguments: contact),
          onLongPress: () async {
            final delete = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.deleteContact),
                content: Text(l10n.deleteContactMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                ],
              ),
            );
            if (delete == true) {
              cubit.deleteContact(contact.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: palette.surfaceAlt,
                  child: Icon(Icons.person, color: palette.textSecondary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        contact.phone,
                        style: text.bodySmall?.copyWith(color: palette.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: palette.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
