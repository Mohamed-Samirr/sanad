import 'package:flutter/material.dart';

/// The habit icon catalogue.
///
/// Habits store a bare codepoint, but building `IconData(codePoint)` at render
/// time defeats Flutter's icon tree-shaking and fails every release build with
/// "Avoid non-constant invocations of IconData". So the stored codepoint is
/// resolved back to a *const* [IconData] from this list instead, which keeps
/// release builds working and ships only the glyphs actually used rather than
/// the whole 1.6 MB Material font.
///
/// Append-only: removing an entry would orphan the icon of any habit already
/// using it, which is what [resolve]'s fallback quietly absorbs.
class HabitIcons {
  const HabitIcons._();

  static const IconData fallback = Icons.bolt_rounded;

  static const List<IconData> catalogue = <IconData>[
    Icons.bolt_rounded,
    Icons.fitness_center_rounded,
    Icons.directions_run_rounded,
    Icons.self_improvement_rounded,
    Icons.mosque_rounded,
    Icons.menu_book_rounded,
    Icons.bedtime_rounded,
    Icons.water_drop_rounded,
    Icons.restaurant_rounded,
    Icons.spa_rounded,
    Icons.code_rounded,
    Icons.music_note_rounded,
    Icons.brush_rounded,
    Icons.savings_rounded,
    Icons.cleaning_services_rounded,
    Icons.local_florist_rounded,
    Icons.edit_note_rounded,
    Icons.favorite_rounded,
  ];

  static final Map<int, IconData> _byCodePoint = <int, IconData>{
    for (final icon in catalogue) icon.codePoint: icon,
  };

  /// The icon for a stored codepoint, or [fallback] if the catalogue no
  /// longer carries it.
  static IconData resolve(int codePoint) =>
      _byCodePoint[codePoint] ?? fallback;
}
