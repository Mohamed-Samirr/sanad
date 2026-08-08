import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/urge_entry.dart';
import '../cubit/urge_flow_cubit.dart';
import '../cubit/urge_flow_state.dart';

class UrgeOutcomePage extends StatefulWidget {
  const UrgeOutcomePage({super.key});

  @override
  State<UrgeOutcomePage> createState() => _UrgeOutcomePageState();
}

class _UrgeOutcomePageState extends State<UrgeOutcomePage> {
  UrgeOutcome? _selectedOutcome;
  String _reflectionNote = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outcome'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<UrgeFlowCubit, UrgeFlowState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'What happened?',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              _OutcomeButton(
                label: 'Passed',
                selected: _selectedOutcome == UrgeOutcome.passed,
                color: Colors.green,
                onTap: () => setState(() => _selectedOutcome = UrgeOutcome.passed),
              ),
              const SizedBox(height: AppSpacing.lg),
              _OutcomeButton(
                label: 'Still fighting',
                selected: _selectedOutcome == UrgeOutcome.ongoing,
                color: Colors.orange,
                onTap: () => setState(() => _selectedOutcome = UrgeOutcome.ongoing),
              ),
              const SizedBox(height: AppSpacing.lg),
              _OutcomeButton(
                label: 'Acted on it',
                selected: _selectedOutcome == UrgeOutcome.actedOn,
                color: Colors.red,
                onTap: () => setState(() => _selectedOutcome = UrgeOutcome.actedOn),
              ),
              if (_selectedOutcome == UrgeOutcome.actedOn) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Reflection',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'What happened before? What did you actually need?',
                  ),
                  maxLines: 3,
                  onChanged: (value) => _reflectionNote = value,
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FilledButton(
          onPressed: _selectedOutcome == null
              ? null
              : () {
                  context.read<UrgeFlowCubit>().submitOutcome(
                        _selectedOutcome!,
                        reflectionNote: _selectedOutcome == UrgeOutcome.actedOn ? _reflectionNote : null,
                      );
                },
          child: const Text('Finish'),
        ),
      ),
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OutcomeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(51) : Theme.of(context).cardColor,
          border: Border.all(
            color: selected ? color : Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? color : null,
                  fontWeight: selected ? FontWeight.bold : null,
                ),
          ),
        ),
      ),
    );
  }
}
