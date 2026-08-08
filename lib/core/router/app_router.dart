import 'package:flutter/material.dart';

import '../../features/habits/habits_routes.dart';
import '../../features/onboarding/onboarding_routes.dart';
import '../../features/settings/settings_routes.dart';
import '../../features/toolbox/toolbox_routes.dart';
import '../../features/urge/urge_routes.dart';
import '../../features/journal/journal_routes.dart';
import '../../features/support/support_routes.dart';

class AppRouter {
  const AppRouter._();

  static const List<Route<dynamic>? Function(RouteSettings)> _routers = [
    OnboardingRoutes.onGenerateRoute,
    UrgeRoutes.onGenerateRoute,
    HabitsRoutes.onGenerateRoute,
    JournalRoutes.onGenerateRoute,
    SupportRoutes.onGenerateRoute,
    ToolboxRoutes.onGenerateRoute,
    SettingsRoutes.onGenerateRoute,
  ];

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    for (final router in _routers) {
      final route = router(settings);
      if (route != null) return route;
    }
    return null;
  }
}
