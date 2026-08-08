import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/urge_entry.dart';
import '../cubit/urge_flow_cubit.dart';
import '../cubit/urge_flow_state.dart';

class UrgeStrategyPage extends StatelessWidget {
  const UrgeStrategyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your move'),
        automaticallyImplyLeading: false, // Prevents backing out accidentally without using the flow
      ),
      body: BlocBuilder<UrgeFlowCubit, UrgeFlowState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _StrategyCard(
                title: 'Delay',
                description: 'Wait it out for 15 minutes with a breathing exercise.',
                icon: Icons.timer,
                onTap: () => context.read<UrgeFlowCubit>().chooseStrategy(UrgeStrategy.delay, delayDurationSec: 900),
              ),
              const SizedBox(height: AppSpacing.lg),
              _StrategyCard(
                title: 'Fight',
                description: 'Use a tool from your toolbox.',
                icon: Icons.build,
                onTap: () {
                  // Normally open a bottom sheet to select a tool, then call chooseStrategy
                  context.read<UrgeFlowCubit>().chooseStrategy(UrgeStrategy.fight);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _StrategyCard(
                title: 'Reach out',
                description: 'Contact your support person.',
                icon: Icons.people,
                onTap: () {
                  context.read<UrgeFlowCubit>().chooseStrategy(UrgeStrategy.reachOut);
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextButton(
                onPressed: () => context.read<UrgeFlowCubit>().chooseStrategy(UrgeStrategy.none),
                child: const Text('Skip strategy'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _StrategyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
          children: [
            Icon(icon, size: 40),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
