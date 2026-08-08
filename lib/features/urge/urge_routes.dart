import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'presentation/cubit/urge_flow_cubit.dart';
import 'presentation/pages/urge_flow_screen.dart';

class UrgeRoutes {
  const UrgeRoutes._();

  static const String urgeFlow = '/urge-flow';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == urgeFlow) {
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<UrgeFlowCubit>(),
          child: const UrgeFlowScreen(),
        ),
      );
    }
    return null;
  }
}
