import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain_exports.dart';

/// The health-score curve. Dots appear only on days the habit was completed,
/// and the dashed line marks the score below which the habit is at risk.
class TrendAreaChart extends StatelessWidget {
  const TrendAreaChart({
    super.key,
    required this.points,
    required this.color,
    required this.riskThreshold,
    this.height = 200,
  });

  final List<HealthPoint> points;
  final Color color;
  final double riskThreshold;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;

    // The line is a foreground mark, so it uses the readable ink rather than
    // the stored pastel — on a light ground the pastel sits near 2:1.
    final line = palette.habitInk(color);

    final axisStyle = text.labelSmall?.copyWith(
      color: palette.textSecondary,
      fontWeight: FontWeight.w400,
    );

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].score),
    ];

    final completedIndexes = <int>{
      for (var i = 0; i < points.length; i++)
        if (points[i].completed) i,
    };

    final labelInterval = (points.length / 5).ceilToDouble().clamp(1.0, 30.0);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: palette.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(value.toInt().toString(), style: axisStyle),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelInterval,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      AppDateUtils.compactDate(points[index].date),
                      style: axisStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: riskThreshold,
                color: palette.caution.withValues(alpha: 0.7),
                strokeWidth: 1,
                dashArray: const [6, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 2, bottom: 2),
                  labelResolver: (_) => 'check-in',
                  style: text.labelSmall?.copyWith(color: palette.caution),
                ),
              ),
            ],
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => palette.surfaceAlt,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final point = points[spot.x.toInt()];
                  final status = point.completed ? 'Done' : 'Missed';
                  return LineTooltipItem(
                    '${AppDateUtils.compactDate(point.date)}  ·  '
                    '${point.score.round()}\n$status',
                    text.labelSmall?.copyWith(color: palette.textPrimary) ??
                        const TextStyle(),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.18,
              preventCurveOverShooting: true,
              color: line,
              barWidth: 2.6,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) =>
                    completedIndexes.contains(spot.x.toInt()),
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: line,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    line.withValues(alpha: 0.28),
                    line.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
