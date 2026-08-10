import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../settings/settings_routes.dart';
import '../../domain_exports.dart';
import '../cubit/habits_cubit.dart';
import '../widgets/habit_check_button.dart';
import '../widgets/habit_icon.dart';
import '../widgets/streak_badge.dart';
import '../widgets/time_of_day_pill.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.habitsTitle),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_habit_fab',
        onPressed: () => Navigator.of(context).pushNamed('/habit-form'),
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocBuilder<HabitsCubit, HabitsState>(
        builder: (context, state) {
          if (state.status == HabitsStatus.loading ||
              state.status == HabitsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.habits.isEmpty) {
            return EmptyState(
              icon: Icons.bolt_rounded,
              title: l10n.noHabitsTitle,
              message: l10n.noHabitsMessage,
              actionLabel: l10n.addHabit,
              onAction: () => Navigator.of(context).pushNamed('/habit-form'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              96,
            ),
            children: [
              _TodaySummary(done: state.doneToday, due: state.dueToday),
              const SizedBox(height: AppSpacing.lg),
              for (final slot in HabitTimeOfDay.values)
                if (state.byTimeOfDay(slot).isNotEmpty)
                  _TimeGroup(slot: slot, habits: state.byTimeOfDay(slot)),
            ],
          );
        },
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.done, required this.due});

  final int done;
  final int due;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final progress = due == 0 ? 0.0 : done / due;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: due == 0
          ? l10n.nothingScheduledToday
          : l10n.doneOfDueTodaySemantics(done, due),
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            height: 52,
            width: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: animate ? 0 : progress, end: progress),
                  duration: Duration(milliseconds: animate ? 600 : 0),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    backgroundColor: palette.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                  ),
                ),
                Text('$done', style: text.titleMedium),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              due == 0
                  ? l10n.nothingScheduledToday
                  : l10n.doneOfDueToday(done, due),
              style: text.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeGroup extends StatelessWidget {
  const _TimeGroup({required this.slot, required this.habits});

  final HabitTimeOfDay slot;
  final List<HabitSummary> habits;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                TimeOfDayPill.iconFor(slot),
                size: 16,
                color: palette.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                TimeOfDayPill.labelFor(context, slot).toUpperCase(),
                style: text.labelMedium?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
        for (final summary in habits) _HabitRow(summary: summary),
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.summary});

  final HabitSummary summary;

  /// Long-press shortcuts, so skipping or editing does not require opening
  /// the detail screen first.
  Future<void> _showRowMenu(BuildContext context) async {
    final cubit = context.read<HabitsCubit>();
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final habit = summary.habit;
    final hasTodayLog = summary.todayLog != null;

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  habit.name,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle_outline_rounded),
              title: Text(l10n.skipToday),
              subtitle: Text(l10n.skipTodayDescription),
              onTap: () => Navigator.of(sheetContext).pop('skip'),
            ),
            if (hasTodayLog)
              ListTile(
                leading: const Icon(Icons.remove_circle_outline_rounded),
                title: Text(l10n.clearTodayEntry),
                onTap: () => Navigator.of(sheetContext).pop('clear'),
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editHabit),
              onTap: () => Navigator.of(sheetContext).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.insights_rounded),
              title: Text(l10n.openDetails),
              onTap: () => Navigator.of(sheetContext).pop('detail'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );

    switch (choice) {
      case 'skip':
        await cubit.skipToday(summary);
      case 'clear':
        await cubit.clearToday(summary);
      case 'edit':
        await navigator.pushNamed('/habit-form', arguments: habit);
      case 'detail':
        await navigator.pushNamed('/habit-detail', arguments: habit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    final habit = summary.habit;
    final stored = AppColors.fromHex(habit.colorHex);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => Navigator.of(context).pushNamed(
            '/habit-detail',
            arguments: habit.id,
          ),
          onLongPress: () => _showRowMenu(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
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
                      if (habit.targetNote != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.targetNote!,
                          style: text.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                StreakBadge(streak: summary.currentStreak),
                const SizedBox(width: AppSpacing.sm),
                HabitCheckButton(
                  isDone: summary.isDoneToday,
                  color: stored,
                  onTap: () => context.read<HabitsCubit>().toggleToday(summary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
