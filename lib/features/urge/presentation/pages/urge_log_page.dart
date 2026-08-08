import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/urge_flow_cubit.dart';
import '../cubit/urge_flow_state.dart';

class UrgeLogPage extends StatelessWidget {
  const UrgeLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Urge'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.read<UrgeFlowCubit>().cancelFlow(),
        ),
      ),
      body: BlocBuilder<UrgeFlowCubit, UrgeFlowState>(
        builder: (context, state) {
          final urge = state.activeUrge;
          if (urge == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'How strong is the urge?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Slider(
                value: urge.intensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: urge.intensity.toString(),
                activeColor: Color.lerp(Colors.green, Colors.red, urge.intensity / 10),
                onChanged: (value) {
                  context.read<UrgeFlowCubit>().updateIntensity(value.toInt());
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'What triggered it?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // Dummy triggers for now, normally loaded from TriggerRepository
              Wrap(
                spacing: AppSpacing.sm,
                children: ['Stress', 'Boredom', 'Tired', 'Hungry', 'Lonely', 'Angry'].map((t) {
                  final selected = urge.triggers.contains(t);
                  return FilterChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (_) => context.read<UrgeFlowCubit>().toggleTrigger(t),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: AppSpacing.sm,
                children: ['Anxious', 'Sad', 'Frustrated', 'Excited'].map((f) {
                  final selected = urge.feelings.contains(f);
                  return FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => context.read<UrgeFlowCubit>().toggleFeeling(f),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'What is happening right now?',
                ),
                onChanged: (value) => context.read<UrgeFlowCubit>().updateNote(value),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FilledButton(
          onPressed: () => context.read<UrgeFlowCubit>().submitLogStep(),
          child: const Text('Next'),
        ),
      ),
    );
  }
}
