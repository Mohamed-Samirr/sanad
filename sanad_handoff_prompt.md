# Project Handoff — Sanad (Flutter)

You are picking up a Flutter project that already has one feature partially built. Read this whole brief before writing code. Follow the existing conventions exactly — consistency with what is there matters more than your own preferences.

---

## 1. What the app is

A private, offline-first companion for someone working against a compulsive habit or addiction (any type: substances, porn, sugar, gaming, doomscrolling). Two pillars:

**Defensive — the urge flow.** The user logs an urge the moment it hits, then picks one of three moves: **Delay** (countdown + breathing), **Fight** (a pre-planned replacement action from their toolbox), **Reach out** (contact a chosen accountability person). Afterwards they log the outcome.

**Offensive — the habit tracker.** The constructive habits being built (gym, sleep, prayer, reading). Each toolbox action can be promoted into a tracked habit.

Core product idea: the battle is won *before* the urge peaks, by tracking feelings, needs and triggers early and pre-deciding your options.

**Copy tone, everywhere in the app:** clinical-calm, non-judgmental. Never "failed", "weak", "dirty". A slip is a data point, not a verdict. Errors explain what happened and how to fix it, in the interface's voice. Empty screens are invitations to act, not mood pieces.

**Required:** a short dismissible disclaimer on first launch and in Settings — this is a self-tracking tool, not medical treatment, and professional help is the right call for severe cases. One short paragraph, no fear-mongering.

---

## 2. Hard technical constraints

- Flutter stable, Dart 3, null safety. Android + iOS.
- **State:** `flutter_bloc`, **Cubit only**, no Bloc events.
- **Architecture:** Clean Architecture, feature-first. Strict direction `presentation → domain ← data`.
- **Persistence:** 100% local. `hive` / `hive_flutter`. **No backend, no Firebase, no network calls anywhere in the app.** No analytics, no crash reporting, no ads.
- **No `build_runner`.** No `freezed`, no `json_serializable`, no generated Hive adapters. Every `TypeAdapter` is hand-written. Keep it that way — the project deliberately has zero codegen.
- DI with `get_it`, registered manually.
- Errors: `dartz` `Either<Failure, T>`. Repositories never throw to presentation.
- Charts: `fl_chart`. Notifications: `flutter_local_notifications` + `timezone`.
- Localization: `flutter_localizations` + ARB. **Arabic (default, full RTL) and English.**

Current `pubspec.yaml` dependencies: `flutter_bloc ^8.1.6`, `dartz ^0.10.1`, `get_it ^7.7.0`, `hive ^2.2.3`, `hive_flutter ^1.1.0`, `fl_chart ^0.69.0`, `uuid ^4.4.2`. Add only what the remaining work genuinely needs.

---

## 3. What already exists

The `habits` feature is built end to end except its create/edit screen. **Read these files before touching anything** — they define the conventions for every feature you add.

```
lib/
├── core/
│   ├── constants/hive_constants.dart      # box names + type ids (10 habit, 11 habitLog)
│   ├── errors/exceptions.dart             # CacheException, NotFoundException
│   ├── errors/failures.dart               # Failure + Cache/NotFound/Validation/Unexpected
│   ├── theme/app_colors.dart              # dark palette + 8-colour habit palette + hex helpers
│   ├── theme/app_spacing.dart             # 4/8/12/16/24/32 scale + radii
│   ├── usecase/usecase.dart               # UseCase<Type, Params>, NoParams
│   ├── utils/date_utils.dart              # AppDateUtils — dayKey, startOfDay/Week/Month, labels
│   └── widgets/{section_card, empty_state}.dart
└── features/habits/
    ├── domain_exports.dart                # barrel for the habit entities
    ├── habits_injection.dart              # initHabitsFeature() + buildHabitDetailCubit()
    ├── habits_routes.dart                 # onGenerateRoute for /habits and /habit-detail
    ├── domain/
    │   ├── entities/{habit, habit_log, habit_stats, habit_detail, habit_summary,
    │   │             health_score_config}.dart
    │   ├── repositories/habit_repository.dart
    │   ├── services/health_score_calculator.dart
    │   └── usecases/{get_habit_summaries, get_habit_detail, toggle_habit_log,
    │                 save_habit, delete_habit}.dart
    ├── data/
    │   ├── models/{habit_model, habit_log_model}.dart   # hand-written TypeAdapters
    │   ├── datasources/habit_local_data_source.dart
    │   └── repositories/habit_repository_impl.dart
    └── presentation/
        ├── cubit/{habits_cubit, habits_state, habit_detail_cubit, habit_detail_state}.dart
        ├── pages/{habits_page, habit_detail_page}.dart
        └── widgets/{habit_header_card, stat_tile, trend_area_chart, completion_calendar,
                     time_of_day_pill, animated_progress_bar, habit_check_button,
                     streak_badge}.dart
test/health_score_calculator_test.dart
```

### Decisions already made — do not reverse them

1. **Only positive intent is stored.** A `HabitLog` is written for `done` or `skipped`. A scheduled day with no log is a miss, computed at read time. Log key is `habitId_yyyy-MM-dd`, so logging is idempotent.
2. **The health score is rebuilt from the habit's first day on every read**, never stored incrementally — so editing an old day corrects the whole curve, not just the tail. Tunables live in `HealthScoreConfig`: start 75, miss −4 compounding ×1.15 per consecutive miss (capped ×3), completion +8 plus +1 per streak day (max +5), unscheduled/skipped days neutral, at-risk threshold 50.
3. `timesPerWeek` habits only lose points on a day when the weekly quota can no longer be met by the days left in that week.
4. All dates are normalised to local midnight through `AppDateUtils` before storage or comparison.
5. Cubits depend on use cases, never on repositories directly — except for `watchChanges()`, which cubits subscribe to so open screens refresh when another screen writes.

### Conventions to match

- One use case per class, single `call()` method.
- One state class per cubit with a `status` enum (`initial/loading/success/failure`) and a `copyWith`. `errorMessage` is intentionally cleared unless passed, so a message shows once.
- No business logic in widgets. No `setState` outside pure animation.
- Reusable widgets take data through parameters only and never read a Cubit.
- Every list has a designed empty state with icon, one-line explanation, and a CTA.
- File header comments explain *why*, not *what*.

---

## 4. Before you write anything

The habits feature was written without a Flutter SDK available and **has never been compiled.** Your first task:

```bash
flutter pub get
flutter analyze
flutter test
```

Fix everything that comes back. The two most likely sources of errors:
- `fl_chart` API drift in `trend_area_chart.dart` — `LineTouchTooltipData`, `FlClipData`, `FlDotData`, and `HorizontalLineLabel` have all changed shape across versions. Check the installed version's API and adapt rather than downgrading.
- Relative import depth in `data/models/*.dart`.

Report what you fixed before moving on.

---

## 5. Remaining work, in order

### Task 1 — Make the app runnable
- `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` → `Hive.initFlutter()` → `initHabitsFeature()` → `runApp`.
- `app.dart`: `MaterialApp` with `onGenerateRoute: HabitsRoutes.onGenerateRoute`, `initialRoute: HabitsRoutes.list`.
- `core/theme/app_theme.dart`: assemble `ThemeData` from `AppColors` and `AppSpacing` — dark theme first, plus a **genuinely designed light theme**, not an inverted dark one. Include text theme, card theme, app bar theme, input decoration theme, filled/text button themes.
- `core/theme/app_text_styles.dart`: a real type scale. Arabic body face IBM Plex Sans Arabic or Cairo, Latin body Inter. Habit names and stat numbers need clear hierarchy; the streak number and the score are the largest type on the detail screen.
- Move the hardcoded `TextStyle`s currently inline in the habit widgets onto the theme.

**Done when:** the app launches to an empty habits list on both platforms with no analyzer warnings.

### Task 2 — Habit create/edit screen (`/habit-form`)
Both existing pages already `pushNamed('/habit-form')`, the list with no arguments and the detail page with a `Habit` argument for editing. Right now that route does not exist and the app throws.

Build `features/habits/presentation/pages/habit_form_page.dart` + `HabitFormCubit`:
- Name (required), icon picker, colour picker restricted to `AppColors.habitPalette`.
- Schedule: every day / specific weekdays / N times per week. Weekday chips, and a 1–7 stepper for the weekly target.
- Time of day: morning / afternoon / evening / anytime.
- Optional target note ("30 minutes", "5 pages").
- Optional reminder time.
- Start date, defaulting to today, never in the future.
- Validation errors surface inline, and also handle the `ValidationFailure`s that `SaveHabit` already returns.
- Editing preserves `id`, `startDate` and history; changing the schedule must not corrupt past logs.
- Register the route in `habits_routes.dart` and the cubit in `habits_injection.dart`.

### Task 3 — Complete the day-logging interactions
Currently tapping a calendar day toggles it instantly with no way to add context.
- Tapping a past day opens a bottom sheet: mark done / mark skipped / clear / add a note. `HabitLog.note` and `HabitLogStatus.skipped` are already modelled and handled by the calculator but have no UI.
- Long-press on a list row: skip today, edit, open detail.
- Add a notes/history list at the bottom of the detail screen: recent logs with their notes, newest first.
- Skipping is deliberate and neutral — it must never read as a failure in the UI.

### Task 4 — Archive management
`archiveHabit` works but archived habits are invisible with no way back.
- An "Archived habits" section in Settings: list, restore, delete permanently.
- Deleting a habit with history requires a double confirmation and states plainly that every logged day goes with it.

### Task 5 — Reminders
`Habit.reminderMinutes` is stored and nothing reads it.
- `core/services/notification_service.dart` wrapping `flutter_local_notifications` + `timezone`.
- Schedule per-habit reminders on save, cancel on delete/archive, reschedule on edit and on app start.
- Handle timezone changes and DST correctly — this is the main risk in this task.
- Request permission at the moment the user sets their first reminder, never at launch.

### Task 6 — Localization and RTL
Every string in the habits feature is currently hardcoded English inside widgets.
- Set up `flutter_localizations` with `app_ar.arb` and `app_en.arb`. Arabic is the default locale.
- Extract every user-facing string. Nothing hardcoded.
- Verify full RTL: mirrored layouts, correct chevron direction in the calendar header, Arabic month and weekday names, week starting Saturday for the Arabic locale (`firstWeekday` is already a parameter on `CompletionCalendar`).
- Test text scaling to 1.3× with no overflow.

### Task 7 — The recovery side
This is the other half of the product and does not exist yet. Build it feature by feature, following the same layer structure and conventions as `habits`. Do not start it until tasks 1–6 are done and the habits feature is clean.

Features, in build order: `onboarding`, `toolbox`, `urge`, `journal`, `support`, `insights`, `settings`.

Key entities to model (Hive type ids 12+, never reuse 10 or 11):

```
Behavior       { id, name, iconCode, colorHex, whyStatement, startDate, createdAt, isArchived }
UrgeEntry      { id, behaviorId, timestamp, intensity(1-10), triggers[], feelings[], note,
                 chosenStrategy(delay|fight|reachOut|none), toolActionId?, delayDurationSec?,
                 outcome(passed|ongoing|actedOn), outcomeAt?, reflectionNote? }
JournalEntry   { id, date, mood(1-5), energy(1-5), sleepQuality(1-5), stress(1-5),
                 feltNote, neededNote, thoughtNote, tags[] }
ToolAction     { id, title, description, durationMin, iconCode, category, timesUsed, timesWorked }
Trigger        { id, label, isCustom }
StreakRecord   { id, behaviorId, startedAt, endedAt?, endReason? }
SupportContact { id, name, phone, messageTemplate }
AppSettings    { locale, themeMode, lockEnabled, reminderTime, smartRemindersEnabled,
                 firstDayOfWeek, onboardingDone }
```

**The urge flow is the most important screen in the app.** Three steps, under 15 seconds, never more than two taps per screen, reachable in one tap from anywhere via a persistent primary action:
1. **Log it** — intensity slider whose colour responds to the value, trigger chips, feeling chips, optional one-line note. Timestamp captured automatically.
2. **Choose your move** — three large cards. *Delay*: full-screen countdown (default 15 min, configurable) with a 4-7-8 breathing animation and the user's own "why" statement, plus extend +5 min. *Fight*: the toolbox as tappable actions, logging which one was used. *Reach out*: one tap to call or send a pre-written message via `url_launcher`.
3. **Outcome** — passed / still fighting / acted on it. If acted on: a calm reflection sheet asking what happened before and what they actually needed. The streak resets, the history is kept, and the entry is labelled a slip.

An urge in progress must survive an app kill — restore it from Hive on launch.

**Insights** is the app's most valuable screen. It must show, at minimum:
- Urge frequency by hour of day and by day of week — this surfaces the user's risk windows.
- Top triggers, ranked.
- Intensity trend over time.
- Success rate per coping strategy, and per toolbox action — which of Delay / Fight / Reach out actually works for *this* user.
- Urge count and average intensity on days habits were completed vs days they were not. Present it as an observation, never as a causal claim and never as a lecture.

### Task 8 — Privacy and data ownership
- App lock: optional PIN or biometrics, PIN in `flutter_secure_storage`, default off.
- Export and import all data as a JSON file (share sheet + file picker). This is the only way data ever leaves the device.
- Erase all data, double confirmation.
- A Settings line stating plainly that there is no tracking of any kind.

### Task 9 — Quality floor
- Unit tests for every use case and every cubit.
- Widget tests for the urge flow and the habit form.
- Replace `CircularProgressIndicator` with skeleton loaders where data comes from Hive.
- Accessibility pass: 4.5:1 contrast minimum, 48dp touch targets, semantic labels on every interactive element, reduced-motion respected.
- Cold start under 2 seconds; open boxes lazily where possible.
- Verify the app works fully in airplane mode and requests no permissions beyond notifications, biometrics, and the dialer intent.

---

## 6. Known technical debt to clean as you pass through it

- The "an open day should not break the streak" logic in `HealthScoreCalculator.buildStats` works but reads badly — refactor it when you touch that file, and keep the tests green.
- Habit accent colours are stored as hex strings and parsed at render time. Fine for now; if it shows up in a profile, cache the parsed `Color`.
- `get_habit_summaries.dart` relies on type inference rather than importing `Habit` directly. Add the explicit import.

---

## 7. How to work

- One task at a time. Run `flutter analyze` and `flutter test` after each, and do not move on with a red build.
- Show me the plan for a task before writing the code for it if the task touches more than five files.
- Never introduce codegen, a backend, or a network call. If you think one is needed, stop and ask.
- If a decision in section 3 seems wrong to you, say so and explain why — but do not silently change it.
