import 'package:flutter/material.dart';

import 'domain/entities/tool_action.dart';
import 'presentation/pages/toolbox_form_page.dart';
import 'presentation/pages/toolbox_page.dart';

class ToolboxRoutes {
  const ToolboxRoutes._();

  static const String toolbox = '/toolbox';
  static const String form = '/toolbox/form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case toolbox:
        return MaterialPageRoute(
          builder: (_) => const ToolboxPage(),
        );
      case form:
        final action = settings.arguments as ToolAction?;
        return MaterialPageRoute(
          builder: (_) => ToolboxFormPage(action: action),
        );
      default:
        return null;
    }
  }
}
