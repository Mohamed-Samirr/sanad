import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../habits/habits_routes.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OnboardingStatus.completed) {
          Navigator.of(context).pushReplacementNamed(HabitsRoutes.list);
        } else if (state.status == OnboardingStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? context.l10n.failureUnexpected),
              ),
            );
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final text = Theme.of(context).textTheme;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    l10n.onboardingTitle,
                    style: text.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _FeatureItem(
                    icon: Icons.shield_outlined,
                    title: l10n.onboardingDefensiveTitle,
                    description: l10n.onboardingDefensiveText,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _FeatureItem(
                    icon: Icons.architecture_rounded,
                    title: l10n.onboardingOffensiveTitle,
                    description: l10n.onboardingOffensiveText,
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: state.status == OnboardingStatus.completing
                        ? null
                        : () => context.read<OnboardingCubit>().completeOnboarding(),
                    child: Text(l10n.onboardingCTA),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 32, color: palette.accent),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
