import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain_exports.dart';
import '../cubit/habit_detail_cubit.dart';
import '../widgets/completion_calendar.dart';
import '../widgets/day_log_sheet.dart';
import '../widgets/habit_header_card.dart';
import '../widgets/log_history_list.dart';
import '../widgets/stat_tile.dart';
import '../widgets/trend_area_chart.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitDetailCubit, HabitDetailState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.failure != current.failure,
      listener: (context, state) {
        if (state.status == HabitDetailStatus.deleted) {
          Navigator.of(context).pop(true);
          return;
        }
        final failure = state.failure;
        if (failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(context.l10n.forFailure(failure))),
            );
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
                tooltip: context.l10n.editHabit,
              ),
              IconButton(
                onPressed: habit == null ? null : () => _confirmRemove(context),
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: context.l10n.removeHabit,
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
      final l10n = context.l10n;
      final failure = state.failure;
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.habitCouldNotOpenTitle,
        message: failure == null
            ? l10n.habitCouldNotOpenMessage
            : l10n.forFailure(failure),
        actionLabel: l10n.goBack,
        onAction: () => Navigator.of(context).pop(),
      );
    }

    return _DetailBody(
      habit: habit,
      stats: stats,
      logsByDay: state.logsByDay,
      recentLogs: state.recentLogs,
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
    final l10n = context.l10n;

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.removeThisHabitTitle, style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.removeThisHabitMessage,
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop('archive'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.surfaceAlt,
                  foregroundColor: palette.textPrimary,
                ),
                child: Text(l10n.archiveHabit),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop('delete'),
                style: TextButton.styleFrom(foregroundColor: palette.caution),
                child: Text(l10n.deletePermanently),
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
    required this.recentLogs,
    required this.focusedMonth,
  });

  final Habit habit;
  final HabitStats stats;
  final Map<String, HabitLog> logsByDay;
  final List<HabitLog> recentLogs;
  final DateTime focusedMonth;

  /// A tap on a day is a considered action now: the sheet can record a skip
  /// or attach a note, neither of which an instant toggle could express.
  Future<void> _openDaySheet(BuildContext context, DateTime date) async {
    final cubit = context.read<HabitDetailCubit>();

    final result = await showModalBottomSheet<DayLogResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DayLogSheet(
        date: date,
        log: logsByDay[AppDateUtils.dayKey(date)],
        isScheduled: habit.isScheduledOn(date),
      ),
    );

    if (result == null) return;

    switch (result.action) {
      case DayLogAction.markDone:
        await cubit.setDay(
          date,
          status: HabitLogStatus.done,
          note: result.note,
        );
      case DayLogAction.markSkipped:
        await cubit.setDay(
          date,
          status: HabitLogStatus.skipped,
          note: result.note,
        );
      case DayLogAction.clear:
        await cubit.clearDay(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    final cubit = context.read<HabitDetailCubit>();
    final l10n = context.l10n;

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
          title: l10n.healthTrendTitle,
          icon: Icons.show_chart_rounded,
          subtitle: _trendSubtitle(l10n, stats),
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
          title: l10n.completionCalendarTitle,
          icon: Icons.calendar_month_rounded,
          child: CompletionCalendar(
            focusedMonth: focusedMonth,
            logsByDay: logsByDay,
            habit: habit,
            color: color,
            onPreviousMonth: cubit.showPreviousMonth,
            onNextMonth: cubit.showNextMonth,
            onDayTap: (date) => _openDaySheet(context, date),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          title: l10n.recentEntriesTitle,
          icon: Icons.notes_rounded,
          subtitle: l10n.recentEntriesSubtitle,
          child: LogHistoryList(
            logs: recentLogs,
            onTapLog: (log) => _openDaySheet(context, log.date),
          ),
        ),
      ],
    );
  }

  static String _trendSubtitle(AppLocalizations l10n, HabitStats stats) {
    final delta = stats.deltaVsLastWeek.round();
    if (delta == 0) return l10n.trendHoldingSteady;
    return delta > 0 ? l10n.trendUp(delta) : l10n.trendDown(delta.abs());
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final delta = stats.deltaVsLastWeek.round();
    final isUp = delta >= 0;

    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: '${isUp ? '+' : '-'}${delta.abs()}',
            label: l10n.statVsLastWeek,
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
            label: l10n.statDaysRatio(
              stats.completedDays,
              stats.scheduledDays,
            ),
            icon: const Icon(Icons.percent_rounded),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatTile(
            value: '${stats.currentStreak}',
            label: l10n.statBest(stats.bestStreak),
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
            context.l10n.notEnoughTrendData,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
      ),
    );
  }
}
