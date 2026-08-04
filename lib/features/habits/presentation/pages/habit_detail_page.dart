import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain_exports.dart';
import '../cubit/habit_detail_cubit.dart';
import '../widgets/completion_calendar.dart';
import '../widgets/habit_header_card.dart';
import '../widgets/stat_tile.dart';
import '../widgets/trend_area_chart.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitDetailCubit, HabitDetailState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == HabitDetailStatus.deleted) {
          Navigator.of(context).pop(true);
          return;
        }
        final message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final habit = state.habit;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              habit?.name ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            actions: [
              IconButton(
                onPressed: habit == null ? null : () => _onEdit(context, habit),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit habit',
              ),
              IconButton(
                onPressed: habit == null ? null : () => _confirmRemove(context),
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Remove habit',
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HabitDetailState state) {
    final habit = state.habit;
    final stats = state.stats;

    if (state.status == HabitDetailStatus.loading ||
        state.status == HabitDetailStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (habit == null || stats == null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'This habit could not be opened',
        message: state.errorMessage ?? 'Try again from the habits list.',
        actionLabel: 'Go back',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    return _DetailBody(
      habit: habit,
      stats: stats,
      logsByDay: state.logsByDay,
      focusedMonth: state.focusedMonth,
    );
  }

  void _onEdit(BuildContext context, Habit habit) {
    Navigator.of(context).pushNamed('/habit-form', arguments: habit);
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final cubit = context.read<HabitDetailCubit>();
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Remove this habit', style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Archiving keeps the history and hides the habit from your '
                'list. Deleting removes every logged day for good.',
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop('archive'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.surfaceAlt,
                  foregroundColor: palette.textPrimary,
                ),
                child: const Text('Archive habit'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop('delete'),
                style: TextButton.styleFrom(foregroundColor: palette.caution),
                child: const Text('Delete permanently'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == 'archive') {
      await cubit.remove(archive: true);
    } else if (choice == 'delete') {
      await cubit.remove();
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.habit,
    required this.stats,
    required this.logsByDay,
    required this.focusedMonth,
  });

  final Habit habit;
  final HabitStats stats;
  final Map<String, HabitLog> logsByDay;
  final DateTime focusedMonth;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    final cubit = context.read<HabitDetailCubit>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        HabitHeaderCard(habit: habit, stats: stats, color: color),
        const SizedBox(height: AppSpacing.lg),
        _StatsRow(stats: stats),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          title: 'Health trend · last 30 days',
          icon: Icons.show_chart_rounded,
          subtitle: _trendSubtitle(stats),
          child: stats.hasEnoughData
              ? TrendAreaChart(
                  points: stats.trend,
                  color: color,
                  riskThreshold: stats.riskThreshold,
                )
              : const _NotEnoughData(),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          title: 'Completion calendar',
          icon: Icons.calendar_month_rounded,
          child: CompletionCalendar(
            focusedMonth: focusedMonth,
            logsByDay: logsByDay,
            habit: habit,
            color: color,
            onPreviousMonth: cubit.showPreviousMonth,
            onNextMonth: cubit.showNextMonth,
            onDayTap: cubit.toggleDay,
          ),
        ),
      ],
    );
  }

  static String _trendSubtitle(HabitStats stats) {
    final delta = stats.deltaVsLastWeek.round();
    if (delta == 0) return 'Holding steady against last week.';
    final direction = delta > 0 ? 'Up' : 'Down';
    return "$direction ${delta.abs()} points on last week's average.";
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final delta = stats.deltaVsLastWeek.round();
    final isUp = delta >= 0;

    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: '${isUp ? '+' : '-'}${delta.abs()}',
            label: 'vs last week',
            icon: Icon(
              isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            ),
            iconColor: isUp ? palette.positive : palette.caution,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            value: '${stats.completionPercent}%',
            label: '${stats.completedDays}/${stats.scheduledDays} days',
            icon: const Icon(Icons.percent_rounded),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            value: '${stats.currentStreak}',
            label: 'best ${stats.bestStreak}',
            icon: const Icon(Icons.local_fire_department_rounded),
            iconColor: palette.caution,
          ),
        ),
      ],
    );
  }
}

class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 140,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Log a few more days and the trend line will show up here.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
      ),
    );
  }
}
