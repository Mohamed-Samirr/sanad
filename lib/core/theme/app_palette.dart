import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app's colour vocabulary, carried on [ThemeData.extensions].
///
/// Material's [ColorScheme] is still populated so its own widgets (dialogs,
/// snack bars, ink splashes) behave, but it has no honest slot for
/// `surfaceAlt`, `textMuted`, `positive` or `caution`. Forcing those into
/// `tertiary`/`outline` would be lossy and would read worse at every call
/// site, so the app's own roles live here and widgets resolve them through
/// `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.divider,
    required this.accent,
    required this.onAccent,
    required this.positive,
    required this.caution,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onHabitFill,
  });

  final Brightness brightness;

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color divider;

  final Color accent;

  /// Foreground for anything filled with [accent].
  final Color onAccent;

  final Color positive;
  final Color caution;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Foreground for anything filled with a habit accent — the stored pastels
  /// are light, so this is dark in both themes.
  final Color onHabitFill;

  bool get isDark => brightness == Brightness.dark;

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    divider: AppColors.darkDivider,
    accent: AppColors.darkAccent,
    onAccent: AppColors.darkBackground,
    positive: AppColors.darkPositive,
    caution: AppColors.darkCaution,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    onHabitFill: AppColors.darkBackground,
  );

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    divider: AppColors.lightDivider,
    accent: AppColors.lightAccent,
    onAccent: AppColors.lightSurface,
    positive: AppColors.lightPositive,
    caution: AppColors.lightCaution,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    onHabitFill: AppColors.lightTextPrimary,
  );

  // ------------------------------------------------------- habit accents

  /// Contrast a habit accent must clear against the ground it is drawn on.
  static const double _minInkContrast = 4.5;

  /// Derived inks are stable per stored colour, so they are memoised rather
  /// than recomputed on every rebuild.
  static final Map<int, Color> _inkCache = <int, Color>{};

  /// A habit accent as a *foreground* — icon, chart line, emphasised number.
  ///
  /// The stored hex is tuned for the dark ground; on light it lands at
  /// roughly 2:1 and is unusable. Rather than storing a second palette, the
  /// hue is preserved and darkened until it clears [_minInkContrast] against
  /// [AppColors.lightSurfaceAlt] — the most demanding light ground it can sit
  /// on, so it is safe on every lighter one too. Custom colours added later
  /// go through the same path.
  Color habitInk(Color stored) {
    if (isDark) return stored;
    return _inkCache.putIfAbsent(
      stored.toARGB32(),
      () => _readableOn(stored, AppColors.lightSurfaceAlt, _minInkContrast),
    );
  }

  /// A habit accent as a *fill* — a completed calendar cell, a progress bar.
  /// The stored pastel is kept in both themes: paired with [onHabitFill] it
  /// measures 6:1 or better, and it is what makes a done day feel warm rather
  /// than administrative.
  Color habitFill(Color stored) => stored;

  /// A habit accent as a faint tint behind an icon. A pastel at 15% on white
  /// is invisible, so light theme tints with the derived ink instead.
  Color habitTint(Color stored) => isDark
      ? stored.withValues(alpha: 0.15)
      : habitInk(stored).withValues(alpha: 0.12);

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  static Color _readableOn(Color colour, Color ground, double target) {
    final base = HSLColor.fromColor(colour);
    // Darkening washes a pastel out; a little saturation back keeps the hue
    // recognisable as the same habit colour across themes.
    final saturated = base.withSaturation(
      (base.saturation * 1.15).clamp(0.0, 1.0),
    );

    var lightness = saturated.lightness;
    while (lightness > 0.05) {
      final candidate = saturated.withLightness(lightness).toColor();
      if (_contrast(candidate, ground) >= target) return candidate;
      lightness -= 0.015;
    }
    return saturated.withLightness(0.05).toColor();
  }

  // -------------------------------------------------------- ThemeExtension

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? divider,
    Color? accent,
    Color? onAccent,
    Color? positive,
    Color? caution,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onHabitFill,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      positive: positive ?? this.positive,
      caution: caution ?? this.caution,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onHabitFill: onHabitFill ?? this.onHabitFill,
    );
  }

  @override
  AppPalette lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onHabitFill: Color.lerp(onHabitFill, other.onHabitFill, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  /// The active palette. Falls back to [AppPalette.dark] so a widget lifted
  /// into a bare test harness still renders.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
