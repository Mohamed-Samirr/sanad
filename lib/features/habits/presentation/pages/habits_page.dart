import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/habit-form'),
        tooltip: 'Add a habit',
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
              title: 'No habits yet',
              message:
                  'Start with one small action you can repeat tomorrow. You '
                  'can promote any toolbox action into a tracked habit.',
              actionLabel: 'Add a habit',
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
    final progress = due == 0 ? 0.0 : done / due;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: due == 0
          ? 'Nothing scheduled today'
          : '$done of $due habits done today',
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
                  ? 'Nothing scheduled today.'
                  : '$done of $due done today',
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
                TimeOfDayPill.labelFor(slot).toUpperCase(),
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
