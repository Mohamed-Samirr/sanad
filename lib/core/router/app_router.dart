import 'package:flutter/material.dart';

import '../../features/habits/habits_routes.dart';
import '../../features/settings/settings_routes.dart';

/// Asks each feature's router in turn.
///
/// Features keep owning their own routes — this only decides who is asked, so
/// adding a feature means adding one line here rather than moving its routes
/// into a central table.
class AppRouter {
  const AppRouter._();

  static const String initialRoute = HabitsRoutes.list;

  static const List<Route<dynamic>? Function(RouteSettings)> _routers = [
    HabitsRoutes.onGenerateRoute,
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
