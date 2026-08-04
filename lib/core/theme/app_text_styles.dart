import 'package:flutter/material.dart';

/// Bundled as assets rather than fetched — `google_fonts` resolves over the
/// network at runtime, which this app does not do under any circumstance.
class AppFonts {
  const AppFonts._();

  static const String latin = 'Inter';
  static const String arabic = 'IBMPlexSansArabic';

  /// Inter carries no Arabic glyphs and IBM Plex Sans Arabic carries a full
  /// Latin set, so each family falls back to the other and mixed strings
  /// ("30 دقيقة") render in one visual voice either way.
  static List<String> fallbackFor(String primary) =>
      primary == arabic ? const [latin] : const [arabic];
}

/// The type scale.
///
/// Three jobs, in descending size: hero numerals (the score and the streak,
/// the largest type anywhere in the app), habit names, then supporting copy.
/// Anything numeric uses tabular figures so a value animating from 9 to 10
/// does not shift the glyphs around it.
class AppTextStyles {
  const AppTextStyles._();

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme({
    required String fontFamily,
    required Color primary,
  }) {
    final fallback = AppFonts.fallbackFor(fontFamily);

    TextStyle style(
      double size,
      FontWeight weight, {
      double? height,
      double? letterSpacing,
      bool numeric = false,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: primary,
        fontFeatures: numeric ? _tabular : null,
      );
    }

    return TextTheme(
      // Hero numerals — the score and the streak on the detail screen.
      displayLarge: style(40, FontWeight.w700, height: 1.05, letterSpacing: -1, numeric: true),
      displayMedium: style(30, FontWeight.w700, height: 1.1, letterSpacing: -0.6, numeric: true),
      // Stat tile values.
      displaySmall: style(26, FontWeight.w700, height: 1.1, letterSpacing: -0.4, numeric: true),

      headlineLarge: style(24, FontWeight.w700, height: 1.2, letterSpacing: -0.3),
      // Page titles.
      headlineMedium: style(22, FontWeight.w700, height: 1.2, letterSpacing: -0.2),
      headlineSmall: style(20, FontWeight.w600, height: 1.25),

      // Section headings and empty-state titles.
      titleLarge: style(17, FontWeight.w600, height: 1.3),
      // Habit names.
      titleMedium: style(16, FontWeight.w600, height: 1.3),
      titleSmall: style(15, FontWeight.w500, height: 1.3),

      bodyLarge: style(15, FontWeight.w400, height: 1.4),
      // Explanatory copy — the loose leading is what keeps the tone calm.
      bodyMedium: style(14, FontWeight.w400, height: 1.45),
      bodySmall: style(13, FontWeight.w400, height: 1.4),

      labelLarge: style(15, FontWeight.w600, height: 1.2),
      // Group eyebrows: MORNING / AFTERNOON.
      labelMedium: style(12, FontWeight.w600, height: 1.2, letterSpacing: 1.1),
      labelSmall: style(11, FontWeight.w600, height: 1.2),
    );
  }
}
