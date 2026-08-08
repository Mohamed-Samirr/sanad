import 'package:flutter/material.dart';
import '../../features/habits/presentation/pages/habits_page.dart';
import '../../features/urge/urge_routes.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/support/presentation/pages/support_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../features/journal/presentation/cubit/journal_cubit.dart';
import '../../features/support/presentation/cubit/support_cubit.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/insights/presentation/cubit/insights_cubit.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HabitsPage(),
          BlocProvider(
            create: (_) => GetIt.I<JournalCubit>()..loadEntries(),
            child: const JournalPage(),
          ),
          BlocProvider(
            create: (_) => GetIt.I<InsightsCubit>()..loadInsights(),
            child: const InsightsPage(),
          ),
          BlocProvider(
            create: (_) => GetIt.I<SupportCubit>()..loadContacts(),
            child: const SupportPage(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'urge_fab',
        onPressed: () {
          Navigator.of(context).pushNamed(UrgeRoutes.urgeFlow);
        },
        backgroundColor: Theme.of(context).colorScheme.error, // or a distinct alert color
        child: const Icon(Icons.shield, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Needed when items > 3
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Build',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
