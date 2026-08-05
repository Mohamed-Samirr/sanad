import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain_exports.dart';
import '../cubit/archived_habits_cubit.dart';
import '../widgets/habit_icon.dart';

class ArchivedHabitsPage extends StatelessWidget {
  const ArchivedHabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivedHabitsCubit, ArchivedHabitsState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure ||
          previous.lastAction != current.lastAction ||
          previous.lastActionHabitName != current.lastActionHabitName,
      listener: (context, state) {
        final message = _message(context, state);
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.archivedHabitsTitle)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  /// The cubit records what happened; the sentence is written here, where the
  /// locale is known.
  String? _message(BuildContext context, ArchivedHabitsState state) {
    final l10n = context.l10n;

    final failure = state.failure;
    if (failure != null) return l10n.forFailure(failure);

    final name = state.lastActionHabitName;
    if (name == null) return null;

    switch (state.lastAction) {
      case ArchivedAction.restored:
        return l10n.restoredMessage(name);
      case ArchivedAction.deleted:
        return l10n.deletedMessage(name);
      case null:
        return null;
    }
  }

  Widget _buildBody(BuildContext context, ArchivedHabitsState state) {
    if (state.status == ArchivedHabitsStatus.loading ||
        state.status == ArchivedHabitsStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.habits.isEmpty) {
      final l10n = context.l10n;
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.nothingArchivedTitle,
        message: l10n.nothingArchivedMessage,
        actionLabel: l10n.backToHabits,
        onAction: () => Navigator.of(context).pop(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: state.habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _ArchivedRow(entry: state.habits[index]),
    );
  }
}

class _ArchivedRow extends StatelessWidget {
  const _ArchivedRow({required this.entry});

  final ArchivedHabit entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final habit = entry.habit;
    final stored = AppColors.fromHex(habit.colorHex);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: palette.habitTint(stored),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  HabitIcons.resolve(habit.iconCodePoint),
                  color: palette.habitInk(stored),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      entry.hasHistory
                          ? l10n.loggedDaysSince(
                              entry.logCount,
                              l10n.shortDate(habit.startDate),
                            )
                          : l10n.noLoggedDaysYet,
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      context.read<ArchivedHabitsCubit>().restore(entry),
                  icon: const Icon(Icons.unarchive_outlined, size: 18),
                  label: Text(l10n.restore),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.surfaceAlt,
                    foregroundColor: palette.textPrimary,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () => _confirmDelete(context, entry),
                style: TextButton.styleFrom(foregroundColor: palette.caution),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Two confirmations when there is history to lose, one when there is not.
  /// The first explains the consequence, the second makes the user act on it
  /// deliberately — an archived habit is easy to tap by accident and the logs
  /// are unrecoverable.
  Future<void> _confirmDelete(BuildContext context, ArchivedHabit entry) async {
    final cubit = context.read<ArchivedHabitsCubit>();
    final l10n = context.l10n;
    final name = entry.habit.name;
    final count = entry.logCount;

    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteHabitTitle(name)),
        content: Text(
          entry.hasHistory
              ? l10n.deleteWithHistoryMessage(count)
              : l10n.deleteNoHistoryMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepIt),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );

    if (first != true) return;

    if (!entry.hasHistory) {
      await cubit.deletePermanently(entry);
      return;
    }

    if (!context.mounted) return;

    final palette = context.palette;
    final second = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.permanentTitle),
        content: Text(l10n.permanentMessage(count, name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: palette.caution),
            child: Text(l10n.deleteForever),
          ),
        ],
      ),
    );

    if (second == true) {
      await cubit.deletePermanently(entry);
    }
  }
}
