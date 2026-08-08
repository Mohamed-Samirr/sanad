import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain_exports.dart';
import 'habits_injection.dart';
import 'presentation/cubit/habits_cubit.dart';
import 'presentation/pages/archived_habits_page.dart';
import 'presentation/pages/habit_detail_page.dart';
import 'presentation/pages/habit_form_page.dart';

import '../../core/widgets/main_layout.dart';

/// Plug these into whatever router the app uses.
class HabitsRoutes {
  const HabitsRoutes._();

  static const String list = '/habits';
  static const String detail = '/habit-detail';
  static const String form = '/habit-form';
  static const String archived = '/archived-habits';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case list:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<HabitsCubit>()
              ..load()
              ..listenToChanges(),
            child: const MainLayout(),
          ),
        );
      case detail:
        final habitId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => buildHabitDetailCubit(habitId)
              ..load()
              ..listenToChanges(),
            child: const HabitDetailPage(),
          ),
        );
      case form:
        // No argument creates, a [Habit] argument edits.
        final habit = settings.arguments as Habit?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => buildHabitFormCubit(habit),
            child: const HabitFormPage(),
          ),
          fullscreenDialog: true,
        );
      case archived:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => buildArchivedHabitsCubit()
              ..load()
              ..listenToChanges(),
            child: const ArchivedHabitsPage(),
          ),
        );
      default:
        return null;
    }
  }
}
