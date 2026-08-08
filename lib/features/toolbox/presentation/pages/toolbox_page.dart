import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../toolbox/toolbox_injection.dart';
import '../../../toolbox/toolbox_routes.dart';
import '../cubit/toolbox_cubit.dart';
import '../cubit/toolbox_state.dart';

class ToolboxPage extends StatelessWidget {
  const ToolboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ToolboxCubit(
        getToolboxActions: sl(),
        repository: sl(),
      )..load()..listenToChanges(),
      child: const _ToolboxView(),
    );
  }
}

class _ToolboxView extends StatelessWidget {
  const _ToolboxView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.toolboxTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addTool,
            onPressed: () => Navigator.of(context).pushNamed(ToolboxRoutes.form),
          ),
        ],
      ),
      body: BlocBuilder<ToolboxCubit, ToolboxState>(
        builder: (context, state) {
          if (state.status == ToolboxStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.actions.isEmpty) {
            return _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.actions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final action = state.actions[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  side: BorderSide(color: palette.divider),
                ),
                leading: CircleAvatar(
                  backgroundColor: palette.surfaceAlt,
                  foregroundColor: palette.accent,
                  child: Icon(IconData(action.iconCode, fontFamily: 'MaterialIcons')),
                ),
                title: Text(action.title),
                subtitle: Text(action.description),
                trailing: Text('${action.durationMin}m', style: TextStyle(color: palette.textSecondary)),
                onTap: () => Navigator.of(context).pushNamed(
                  ToolboxRoutes.form,
                  arguments: action,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.build_circle_outlined, size: 64, color: palette.textSecondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noToolsTitle,
            style: text.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.noToolsMessage,
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(ToolboxRoutes.form),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTool),
          ),
        ],
      ),
    );
  }
}
