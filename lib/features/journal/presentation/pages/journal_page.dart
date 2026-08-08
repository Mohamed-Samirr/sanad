import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../settings/settings_routes.dart';
import '../../domain/entities/journal_entry.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.journalTitle),
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
        heroTag: 'add_journal_fab',
        onPressed: () => Navigator.of(context).pushNamed('/journal-form'),
        tooltip: l10n.addJournalEntry,
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocBuilder<JournalCubit, JournalState>(
        builder: (context, state) {
          if (state.status == JournalStatus.loading || state.status == JournalStatus.initial) {
            final animate = !MediaQuery.disableAnimationsOf(context);
            return Center(
              child: animate 
                  ? const CircularProgressIndicator() 
                  : const CircularProgressIndicator(value: 0),
            );
          }

          if (state.entries.isEmpty) {
            return EmptyState(
              icon: Icons.book_outlined,
              title: l10n.noJournalEntriesTitle,
              message: l10n.noJournalEntriesMessage,
              actionLabel: l10n.addJournalEntry,
              onAction: () => Navigator.of(context).pushNamed('/journal-form'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            itemCount: state.entries.length,
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              return _JournalRow(entry: entry);
            },
          );
        },
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => Navigator.of(context).pushNamed('/journal-form', arguments: entry),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(entry.date),
                      style: text.labelLarge?.copyWith(color: palette.textSecondary),
                    ),
                    Row(
                      children: [
                        Icon(Icons.mood_rounded, size: 16, color: palette.accent),
                        const SizedBox(width: 4),
                        Text('${entry.mood}/5', style: text.labelMedium),
                      ],
                    ),
                  ],
                ),
                if (entry.feltNote != null && entry.feltNote!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    entry.feltNote!,
                    style: text.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: entry.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: text.labelSmall?.copyWith(color: palette.textSecondary),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
