# Habits feature — Sanad

Clean Architecture + Cubit + Hive. No backend, no codegen.

## Wire it up

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initHabitsFeature();
  runApp(const SanadApp());
}

// inside MaterialApp
onGenerateRoute: HabitsRoutes.onGenerateRoute,
initialRoute: HabitsRoutes.list,
```

## Layers

- `domain/` — entities, repository contract, use cases, and the score
  calculator. Pure Dart, no Flutter or Hive imports, so it can be unit tested
  without a device.
- `data/` — Hive models with hand-written `TypeAdapter`s (no `build_runner`
  step), the local data source, and the repository implementation that maps
  exceptions to `Failure`s.
- `presentation/` — two cubits, two pages, seven reusable widgets. No business
  logic in widgets, no `setState` outside animation.

## Health score

Rebuilt from the first day of the habit on every read, never stored
incrementally — so editing an old day corrects the whole curve instead of only
the tail. Tunables live in `HealthScoreConfig`:

| Rule | Default |
| --- | --- |
| Starting score | 75 |
| Miss | −4, compounding ×1.15 per consecutive miss, capped at ×3 |
| Completion | +8, plus +1 per streak day (max +5) |
| Unscheduled or skipped day | neutral |
| At-risk threshold | 50 |

`timesPerWeek` habits only lose points on a day when the weekly quota can no
longer be met by the days left in that week.

## Storage

Only completions and deliberate skips are written. A scheduled day with no log
is a miss, computed at read time — the box stays small and back-filling a day
is one write. Log keys are `habitId_yyyy-MM-dd`, so logging is idempotent.

## Tests

```bash
flutter test
```

`test/health_score_calculator_test.dart` covers decay, streaks, weekday
schedules, the weekly-quota rule, and back-filling.

## Still to hook in

- `/habit-form` route (create/edit screen) — the detail and list pages already
  navigate to it.
- Reminder scheduling from `Habit.reminderMinutes`.
- Promoting a toolbox action into a habit (`Habit.linkedToolActionId`).
