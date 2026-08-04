import 'package:flutter/material.dart';

/// Raw swatches only. Nothing in the app should read these directly —
/// widgets resolve colour through `context.palette` so the same widget can
/// render on either theme. See [AppPalette].
///
/// The light set is designed on its own terms rather than derived by
/// inverting the dark one: pastels that read cleanly on a near-black ground
/// collapse to ~2:1 on white, so every light accent is a re-picked, darker
/// hue that clears 4.5:1 on the lightest surface it can land on.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------- dark
  static const Color darkBackground = Color(0xFF0E1117);
  static const Color darkSurface = Color(0xFF171B22);
  static const Color darkSurfaceAlt = Color(0xFF1F242D);
  static const Color darkDivider = Color(0xFF262C36);

  static const Color darkAccent = Color(0xFFB9A9FF);
  static const Color darkPositive = Color(0xFF4ECDC4);
  static const Color darkCaution = Color(0xFFF4A261);

  static const Color darkTextPrimary = Color(0xFFF2F4F8);
  static const Color darkTextSecondary = Color(0xFF98A0AE);

  /// Lifted from the original `0xFF5B6472`, which sat at 2.60:1 on
  /// [darkSurfaceAlt] — unreadable even for the de-emphasised day numbers it
  /// is used for. This clears 3:1 on every dark ground.
  static const Color darkTextMuted = Color(0xFF737C8B);

  // --------------------------------------------------------------- light
  static const Color lightBackground = Color(0xFFFAF9F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF0EEEA);
  static const Color lightDivider = Color(0xFFE3E0DA);

  static const Color lightAccent = Color(0xFF5A3EC8);
  static const Color lightPositive = Color(0xFF0F766E);
  static const Color lightCaution = Color(0xFF9A5B12);

  static const Color lightTextPrimary = Color(0xFF17181C);
  static const Color lightTextSecondary = Color(0xFF5A6070);
  static const Color lightTextMuted = Color(0xFF7C8291);

  // ------------------------------------------------------- habit accents
  /// Curated habit accents. Stored on the habit as a hex string, so this list
  /// is the identity of the colour and must stay stable — the light theme
  /// derives a readable variant at render time instead of storing a second
  /// set. See [AppPalette.habitInk].
  static const List<String> habitPalette = <String>[
    'FFF2D857',
    'FFB9A9FF',
    'FF4ECDC4',
    'FFF4A261',
    'FF7FB3FF',
    'FFE27396',
    'FF8DD35F',
    'FFFF9F68',
  ];

  static Color fromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    return Color(int.parse(value, radix: 16));
  }

  static String toHex(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
}
