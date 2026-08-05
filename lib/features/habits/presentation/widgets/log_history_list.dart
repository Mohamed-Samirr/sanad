import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain_exports.dart';

/// Recent entries, newest first.
///
/// Only recorded days appear. Misses are computed at read time and are
/// deliberately absent here — the history is a record of what the user chose
/// to do, not a list of days they let slip.
class LogHistoryList extends StatelessWidget {
  const LogHistoryList({
    super.key,
    required this.logs,
    required this.onTapLog,
    this.maxEntries = 10,
  });

  final List<HabitLog> logs;
  final ValueChanged<HabitLog> onTapLog;
  final int maxEntries;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          context.l10n.nothingLoggedYet,
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      );
    }

    final visible = logs.take(maxEntries).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) Divider(height: AppSpacing.lg, color: palette.divider),
          _LogRow(log: visible[i], onTap: () => onTapLog(visible[i])),
        ],
        if (logs.length > visible.length) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.moreInCalendar(logs.length - visible.length),
            style: text.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log, required this.onTap});

  final HabitLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isDone = log.isDone;
    // Skipped is never coloured as a warning. It reads as a chosen pause.
    final accent = isDone ? palette.positive : palette.accent;
    final label = isDone ? l10n.statusDone : l10n.statusSkipped;
    final icon = isDone
        ? Icons.check_circle_outline_rounded
        : Icons.pause_circle_outline_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.shortDate(log.date),
                          style: text.titleSmall,
                        ),
                      ),
                      Text(
                        label,
                        style: text.bodySmall?.copyWith(color: accent),
                      ),
                    ],
                  ),
                  if (log.note != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      log.note!,
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
