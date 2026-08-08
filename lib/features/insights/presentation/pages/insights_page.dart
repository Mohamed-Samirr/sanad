import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../urge/domain/entities/urge_entry.dart';
import '../cubit/insights_cubit.dart';
import '../cubit/insights_state.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        builder: (context, state) {
          if (state.status == InsightsStatus.loading || state.status == InsightsStatus.initial) {
            final animate = !MediaQuery.disableAnimationsOf(context);
            return Center(
              child: animate 
                  ? const CircularProgressIndicator() 
                  : const CircularProgressIndicator(value: 0),
            );
          }

          if (state.status == InsightsStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Error loading insights'));
          }

          final calc = state.calculator!;
          if (calc.urges.isEmpty) {
            return const Center(child: Text('No data yet. Track some urges to see insights.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard(
                  title: 'Urges by Hour',
                  child: SizedBox(
                    height: 200,
                    child: _buildHourlyChart(context, calc.urgesByHour),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Top Triggers',
                  child: _buildTopTriggers(context, calc.topTriggers),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Strategy Success Rate',
                  child: SizedBox(
                    height: 200,
                    child: _buildStrategyChart(calc.successRateByStrategy),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(BuildContext context, Map<int, int> data) {
    final spots = data.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
    final accent = context.palette.accent;
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}:00');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: accent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: accent.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTriggers(BuildContext context, List<MapEntry<String, int>> triggers) {
    if (triggers.isEmpty) return const Text('No triggers recorded.');
    
    final accent = context.palette.accent;
    
    return Column(
      children: triggers.take(5).map((e) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(e.key),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${e.value}',
              style: TextStyle(fontWeight: FontWeight.bold, color: accent),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStrategyChart(Map<UrgeStrategy, List<int>> data) {
    final sections = <PieChartSectionData>[];
    
    final colors = {
      UrgeStrategy.delay: Colors.blue,
      UrgeStrategy.fight: Colors.red,
      UrgeStrategy.reachOut: Colors.green,
      UrgeStrategy.none: Colors.grey,
    };

    data.forEach((strategy, stats) {
      if (stats[1] == 0) return; // skip if total is 0
      final percentage = (stats[0] / stats[1]) * 100;
      
      sections.add(
        PieChartSectionData(
          color: colors[strategy],
          value: percentage,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    if (sections.isEmpty) {
      return const Center(child: Text('No strategy data yet.'));
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
