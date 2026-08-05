import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/l10n/app_localizations.dart';
import 'package:sanad/core/l10n/app_localizations_ar.dart';
import 'package:sanad/core/l10n/app_localizations_en.dart';

/// The project runs with zero codegen, so the `.arb` files and the hand-written
/// `AppLocalizations` classes are maintained separately. That is only safe if
/// something fails loudly when they drift — which is this file's whole job.
void main() {
  Set<String> arbKeys(String path) {
    final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    return json.keys.where((k) => !k.startsWith('@')).toSet();
  }

  /// Members that are intentionally not translatable strings: locale data,
  /// and the date helpers implemented once on the base class.
  const notInArb = <String>{
    'monthNames',
    'weekdayNamesShort',
    'firstWeekday',
    'shortDate',
    'monthTitle',
    'compactDate',
    // Maps a failure onto one of the failure* keys; not a key itself.
    'forFailure',
  };

  late Set<String> en;
  late Set<String> ar;

  setUp(() {
    en = arbKeys('lib/l10n/app_en.arb');
    ar = arbKeys('lib/l10n/app_ar.arb');
  });

  test('both ARB files carry exactly the same keys', () {
    expect(
      en.difference(ar),
      isEmpty,
      reason: 'these keys have no Arabic translation',
    );
    expect(
      ar.difference(en),
      isEmpty,
      reason: 'these keys have no English translation',
    );
  });

  test('every AppLocalizations member has an ARB entry, and vice versa', () {
    final source =
        File('lib/core/l10n/app_localizations.dart').readAsStringSync();

    final declared = <String>{
      // `String get someKey;`
      ...RegExp(r'^\s*String get (\w+);', multiLine: true)
          .allMatches(source)
          .map((m) => m.group(1)!),
      // `String someKey(int a, String b);`
      ...RegExp(r'^\s*String (\w+)\(', multiLine: true)
          .allMatches(source)
          .map((m) => m.group(1)!),
    }..removeAll(notInArb);

    expect(
      declared.difference(en),
      isEmpty,
      reason: 'declared in AppLocalizations but missing from the ARB files',
    );
    expect(
      en.difference(declared),
      isEmpty,
      reason: 'present in the ARB files but not declared in AppLocalizations',
    );
  });

  test('no ARB value is left as the English text in the Arabic file', () {
    final enJson =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
    final arJson =
        jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync()) as Map<String, dynamic>;

    // "Sanad" is a proper noun and the only value allowed to be identical.
    const sharedValues = <String>{'appTitle'};

    for (final key in en) {
      if (sharedValues.contains(key)) continue;
      expect(
        arJson[key],
        isNot(equals(enJson[key])),
        reason: '$key looks untranslated',
      );
    }
  });

  test('both implementations answer every member without throwing', () {
    for (final AppLocalizations l10n in [
      const AppLocalizationsEn(),
      const AppLocalizationsAr(),
    ]) {
      expect(l10n.monthNames, hasLength(12));
      expect(l10n.weekdayNamesShort, hasLength(7));
      expect(l10n.habitsTitle, isNotEmpty);
      expect(l10n.doneOfDueToday(1, 3), contains('3'));
      expect(l10n.shortDate(DateTime(2026, 3, 4)), contains('2026'));
      expect(l10n.monthTitle(DateTime(2026, 3, 4)), isNotEmpty);
    }
  });

  test('Arabic weeks start on Saturday and English on Monday', () {
    expect(const AppLocalizationsAr().firstWeekday, DateTime.saturday);
    expect(const AppLocalizationsEn().firstWeekday, DateTime.monday);
  });
}
