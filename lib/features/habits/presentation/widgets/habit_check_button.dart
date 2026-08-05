import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';

class HabitCheckButton extends StatelessWidget {
  const HabitCheckButton({
    super.key,
    required this.isDone,
    required this.color,
    required this.onTap,
    this.size = 44,
  });

  final bool isDone;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fill = palette.habitFill(color);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Semantics(
      button: true,
      selected: isDone,
      label: isDone ? context.l10n.checkDoneToday : context.l10n.checkMarkDone,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        // 48dp target regardless of the painted size.
        child: SizedBox(
          height: 48,
          width: 48,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? fill : Colors.transparent,
                border: Border.all(
                  color: isDone ? fill : palette.divider,
                  width: 2,
                ),
              ),
              child: AnimatedScale(
                scale: isDone ? 1 : 0,
                duration: duration,
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.check_rounded,
                  size: size * 0.55,
                  color: palette.onHabitFill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
