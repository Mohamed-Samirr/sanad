import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 12,
  });

  /// 0.0 – 1.0
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fill = palette.habitFill(color);
    // Respect the OS reduced-motion setting rather than animating regardless.
    final animate = !MediaQuery.disableAnimationsOf(context);
    final target = value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : target, end: target),
      duration: Duration(milliseconds: animate ? 700 : 0),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                Container(
                  height: height,
                  width: constraints.maxWidth * animated,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    gradient: LinearGradient(
                      colors: [fill.withValues(alpha: 0.75), fill],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
