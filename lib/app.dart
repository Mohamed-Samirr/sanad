import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/habits/habits_routes.dart';

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Dark until Settings can expose the choice — the light theme is built
      // and designed, just not reachable yet.
      themeMode: ThemeMode.dark,
      initialRoute: HabitsRoutes.list,
      onGenerateRoute: HabitsRoutes.onGenerateRoute,
    );
  }
}
