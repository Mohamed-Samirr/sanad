import '../../../urge/domain/entities/urge_entry.dart';
import '../../../urge/domain/entities/trigger.dart';

class InsightsCalculator {
  final List<UrgeEntry> urges;
  final List<Trigger> triggers;

  InsightsCalculator({required this.urges, required this.triggers});

  /// Groups urges by hour of day (0-23)
  Map<int, int> get urgesByHour {
    final map = <int, int>{};
    for (var i = 0; i < 24; i++) {
      map[i] = 0;
    }
    for (final urge in urges) {
      final hour = urge.timestamp.hour;
      map[hour] = (map[hour] ?? 0) + 1;
    }
    return map;
  }

  /// Groups urges by day of week (1=Monday ... 7=Sunday)
  Map<int, int> get urgesByDayOfWeek {
    final map = <int, int>{};
    for (var i = 1; i <= 7; i++) {
      map[i] = 0;
    }
    for (final urge in urges) {
      final weekday = urge.timestamp.weekday;
      map[weekday] = (map[weekday] ?? 0) + 1;
    }
    return map;
  }

  /// Calculates success rate (passed vs actedOn) per strategy.
  /// Returns a map of Strategy to [successCount, totalCount]
  Map<UrgeStrategy, List<int>> get successRateByStrategy {
    final map = <UrgeStrategy, List<int>>{};
    for (final strategy in UrgeStrategy.values) {
      map[strategy] = [0, 0]; // [successes, total]
    }

    for (final urge in urges) {
      if (urge.outcome == null || urge.outcome == UrgeOutcome.ongoing) continue;
      
      final stats = map[urge.chosenStrategy]!;
      stats[1] += 1; // total
      if (urge.outcome == UrgeOutcome.passed) {
        stats[0] += 1; // success
      }
    }
    return map;
  }

  /// Ranks triggers by the number of times they appeared in urges
  List<MapEntry<String, int>> get topTriggers {
    final countMap = <String, int>{};
    for (final urge in urges) {
      for (final triggerId in urge.triggers) {
        countMap[triggerId] = (countMap[triggerId] ?? 0) + 1;
      }
    }

    // Map IDs to names
    final namedMap = <String, int>{};
    for (final entry in countMap.entries) {
      final trigger = triggers.where((t) => t.id == entry.key).firstOrNull;
      final name = trigger?.label ?? 'Unknown';
      namedMap[name] = (namedMap[name] ?? 0) + entry.value;
    }

    final sortedList = namedMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return sortedList;
  }
}
