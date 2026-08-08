import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'domain/entities/journal_entry.dart';
import 'presentation/cubit/journal_cubit.dart';
import 'presentation/pages/journal_form_page.dart';
import 'presentation/pages/journal_page.dart';

class JournalRoutes {
  static const String list = '/journal';
  static const String form = '/journal-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case list:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.I<JournalCubit>()..loadEntries(),
            child: const JournalPage(),
          ),
        );
      case form:
        final entry = settings.arguments as JournalEntry?;
        return MaterialPageRoute(
          builder: (_) => JournalFormPage(initialEntry: entry),
        );
      default:
        return null;
    }
  }
}
