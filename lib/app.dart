import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SanadApp extends StatelessWidget {
  const SanadApp({
    super.key,
    required this.initialRoute,
    this.locale,
  });

  final String initialRoute;

  /// Forces a locale instead of following the device. Null means "follow the
  /// device", which is the shipping behaviour; Settings will drive this once
  /// `AppSettings.locale` exists.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: locale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Dark until Settings can expose the choice — the light theme is built
      // and designed, just not reachable yet.
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: _resolveLocale,
      // Applied after the locale is known, which the top-level `theme` cannot
      // be — the two faces have different metrics, so the Arabic build reads
      // better with IBM Plex Sans Arabic leading rather than Inter.
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final fontFamily =
            locale.languageCode == 'ar' ? AppFonts.arabic : AppFonts.latin;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Theme(
          data: isDark
              ? AppTheme.dark(fontFamily: fontFamily)
              : AppTheme.light(fontFamily: fontFamily),
          child: state.isUnlocked ? (child ?? const SizedBox.shrink()) : _buildLockScreen(context, state),
        );
      },
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
        },
      ),
    );
  }

  Widget _buildLockScreen(BuildContext context, SettingsState state) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            if (state.isBiometricsEnabled)
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with Biometrics'),
                onPressed: () {
                  context.read<SettingsCubit>().authenticateWithBiometrics('Unlock Sanad');
                },
              )
            else
              ElevatedButton(
                child: const Text('Unlock with PIN'),
                onPressed: () {
                  // TODO: Show PIN pad
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Arabic is the app's default. A device set to a language the app speaks
  /// gets that language; anything else lands on Arabic rather than English.
  static Locale? _resolveLocale(Locale? device, Iterable<Locale> supported) {
    if (device != null) {
      for (final locale in supported) {
        if (locale.languageCode == device.languageCode) return locale;
      }
    }
    return const Locale('ar');
  }
}
