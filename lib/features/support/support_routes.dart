import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../urge/domain/entities/support_contact.dart';
import 'presentation/cubit/support_cubit.dart';
import 'presentation/pages/support_form_page.dart';
import 'presentation/pages/support_page.dart';

class SupportRoutes {
  static const String list = '/support';
  static const String form = '/support-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case list:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.I<SupportCubit>()..loadContacts(),
            child: const SupportPage(),
          ),
        );
      case form:
        final contact = settings.arguments as SupportContact?;
        return MaterialPageRoute(
          builder: (_) => SupportFormPage(initialContact: contact),
        );
      default:
        return null;
    }
  }
}
