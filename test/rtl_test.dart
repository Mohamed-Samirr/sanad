import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sanad/main.dart';
import 'package:sanad/core/l10n/app_localizations_ar.dart';
import 'package:sanad/features/settings/settings_injection.dart' hide sl;
import 'package:sanad/features/habits/habits_injection.dart';
import 'package:sanad/features/journal/journal_injection.dart';
import 'package:sanad/features/urge/urge_injection.dart';
import 'package:sanad/features/support/support_injection.dart';

/// Arabic is the default locale and the app has to work right-to-left, so
/// these check the things that silently break in RTL: the reading direction
/// itself, the week start, and layouts that overflow once the strings get
/// longer or the text scales up.
void main() {
  late Directory boxDir;

  setUp(() async {
    await sl.reset();
    boxDir = await Directory.systemTemp.createTemp('sanad_rtl_');
    Hive.init(boxDir.path);
    await initSettingsFeature();
    await initHabitsFeature();
    await initJournalFeature();
    await initUrgeFeature();
    await initSupportFeature();
  });

  tearDown(() async {
    await disposeHabitsFeature();
    await Hive.deleteFromDisk();
    await Hive.close();
    await sl.reset();
    if (boxDir.existsSync()) {
      await boxDir.delete(recursive: true);
    }
  });

  /// The test platform reports an English locale, so Arabic is forced here.
  /// Falling back to Arabic for an *unsupported* locale is covered separately.
  Future<void> pumpApp(WidgetTester tester, {double textScale = 1.0}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const SanadApp(locale: Locale('ar'), initialRoute: '/habits'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('defaults to Arabic and lays out right-to-left', (tester) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(context).languageCode, 'ar');
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('shows the Arabic empty state, not the English one',
      (tester) async {
    await pumpApp(tester);

    const ar = AppLocalizationsAr();
    expect(find.text(ar.noHabitsTitle), findsOneWidget);
    expect(find.text('No habits yet'), findsNothing);
  });

  testWidgets('an unsupported device locale falls back to Arabic, not English',
      (tester) async {
    await tester.pumpWidget(
      const SanadApp(locale: Locale('fr'), initialRoute: '/habits'),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(context).languageCode, 'ar');
  });

  testWidgets('a supported device locale is honoured', (tester) async {
    await tester.pumpWidget(const SanadApp(locale: Locale('en'), initialRoute: '/habits'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(context).languageCode, 'en');
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('the Arabic empty state survives 1.3x text scaling',
      (tester) async {
    await pumpApp(tester, textScale: 1.3);

    expect(tester.takeException(), isNull);
    expect(find.text(const AppLocalizationsAr().noHabitsTitle), findsOneWidget);
  });

  testWidgets('the habit form survives 1.3x text scaling in Arabic',
      (tester) async {
    await pumpApp(tester, textScale: 1.3);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // Every schedule mode is rendered, since each swaps in a different set of
    // controls underneath. The form scrolls, so each chip is brought into
    // view before it is tapped.
    const ar = AppLocalizationsAr();
    for (final label in [ar.scheduleWeekdays, ar.scheduleTimesPerWeek]) {
      final chip = find.text(label);
      await tester.scrollUntilVisible(chip, 120, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflowed on $label');
    }
  });

  test('the Arabic week starts on Saturday', () {
    expect(const AppLocalizationsAr().firstWeekday, DateTime.saturday);
  });
}
