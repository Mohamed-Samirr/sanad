import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/settings_injection.dart';
import 'presentation/cubit/onboarding_cubit.dart';
import 'presentation/pages/onboarding_page.dart';

class OnboardingRoutes {
  const OnboardingRoutes._();

  static const String onboarding = '/onboarding';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == onboarding) {
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OnboardingCubit(
            getSettings: sl(),
            updateSettings: sl(),
          ),
          child: const OnboardingPage(),
        ),
      );
    }
    return null;
  }
}
