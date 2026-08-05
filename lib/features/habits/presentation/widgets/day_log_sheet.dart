import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain_exports.dart';

enum DayLogAction { markDone, markSkipped, clear }

class DayLogResult {
  final DayLogAction action;
  final String? note;

  const DayLogResult(this.action, {this.note});
}

/// The sheet behind a tap on a calendar day.
///
/// Pops a [DayLogResult] instead of taking callbacks so it stays a pure
/// widget with no idea a cubit exists — the page decides what a choice means.
class DayLogSheet extends StatefulWidget {
  const DayLogSheet({
    super.key,
    required this.date,
    required this.log,
    required this.isScheduled,
  });

  final DateTime date;

  /// The existing entry for this day, or null when nothing was recorded.
  final HabitLog? log;

  final bool isScheduled;

  @override
  State<DayLogSheet> createState() => _DayLogSheetState();
}

class _DayLogSheetState extends State<DayLogSheet> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.log?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _currentState(AppLocalizations l10n) {
    final log = widget.log;
    if (log == null) {
      return widget.isScheduled
          ? l10n.dayNotRecordedYet
          : l10n.dayNotScheduled;
    }
    return log.isDone ? l10n.dayMarkedDone : l10n.dayMarkedSkipped;
  }

  void _close(DayLogAction action) {
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      DayLogResult(action, note: note.isEmpty ? null : note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isDone = widget.log?.isDone ?? false;
    final isSkipped = widget.log?.status == HabitLogStatus.skipped;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          // Clears the keyboard when the note field has focus.
          bottom: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.shortDate(widget.date), style: text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _currentState(l10n),
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Option(
              icon: Icons.check_circle_outline_rounded,
              label: l10n.markDone,
              description: l10n.markDoneDescription,
              isSelected: isDone,
              accent: palette.positive,
              onTap: () => _close(DayLogAction.markDone),
            ),
            const SizedBox(height: AppSpacing.md),
            _Option(
              icon: Icons.pause_circle_outline_rounded,
              label: l10n.markSkipped,
              // A skip is a decision the user is allowed to make. It has to
              // read as neutral here, because this is the moment they might
              // otherwise feel judged for it.
              description: l10n.markSkippedDescription,
              isSelected: isSkipped,
              accent: palette.accent,
              onTap: () => _close(DayLogAction.markSkipped),
            ),
            if (widget.log != null) ...[
              const SizedBox(height: AppSpacing.md),
              _Option(
                icon: Icons.remove_circle_outline_rounded,
                label: l10n.clearThisDay,
                description: l10n.clearThisDayDescription,
                isSelected: false,
                accent: palette.textSecondary,
                onTap: () => _close(DayLogAction.clear),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                labelText: l10n.noteOptional,
                hintText: l10n.noteHint,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noteSavedWithChoice,
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? accent : palette.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: isSelected ? accent : palette.textSecondary),
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
              if (isSelected)
                Icon(Icons.check_rounded, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
