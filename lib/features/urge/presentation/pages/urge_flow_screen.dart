import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/urge_flow_cubit.dart';
import '../cubit/urge_flow_state.dart';
import 'urge_log_page.dart';
import 'urge_strategy_page.dart';
import 'urge_outcome_page.dart';

class UrgeFlowScreen extends StatefulWidget {
  const UrgeFlowScreen({super.key});

  @override
  State<UrgeFlowScreen> createState() => _UrgeFlowScreenState();
}

class _UrgeFlowScreenState extends State<UrgeFlowScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UrgeFlowCubit>().initializeFlow();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UrgeFlowCubit, UrgeFlowState>(
      listener: (context, state) {
        if (state.status == UrgeFlowStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.status == UrgeFlowStatus.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state.status == UrgeFlowStatus.initial || state.status == UrgeFlowStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.activeUrge == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Could not start urge flow.')),
          );
        }

        switch (state.status) {
          case UrgeFlowStatus.logging:
            return const UrgeLogPage();
          case UrgeFlowStatus.strategizing:
            return const UrgeStrategyPage();
          case UrgeFlowStatus.outcome:
            return const UrgeOutcomePage();
          default:
            return const UrgeLogPage(); // fallback
        }
      },
    );
  }
}
