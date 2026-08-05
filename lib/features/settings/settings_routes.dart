import 'package:flutter/material.dart';

import 'presentation/pages/settings_page.dart';

/// Settings owns no state of its own yet, so there is no cubit to provide —
/// each section brings its own when it needs one.
class SettingsRoutes {
  const SettingsRoutes._();

  static const String settings = '/settings';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return null;
    }
  }
}
