import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:get_it/get_it.dart';

import 'app.dart';
import 'core/usecase/usecase.dart';
import 'features/habits/habits_injection.dart';
import 'features/habits/habits_routes.dart';
import 'features/onboarding/onboarding_routes.dart';
import 'features/settings/domain/usecases/get_settings.dart';
import 'features/settings/settings_injection.dart';
import 'features/toolbox/toolbox_injection.dart';
import 'features/urge/urge_injection.dart';
import 'features/journal/journal_injection.dart';
import 'features/support/support_injection.dart';
import 'features/insights/insights_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await initSettingsFeature();
  await initToolboxFeature();
  await initHabitsFeature();
  await initUrgeFeature();
  await initJournalFeature();
  await initSupportFeature();
  initInsightsFeature();

  final getSettings = GetIt.I<GetSettings>();
  final settingsResult = await getSettings(const NoParams());
  final settings = settingsResult.getOrElse(() => throw Exception('Failed to load settings'));
  final initialRoute = settings.onboardingDone ? HabitsRoutes.list : OnboardingRoutes.onboarding;

  runApp(SanadApp(initialRoute: initialRoute));
}
