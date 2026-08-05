# CLAUDE.md

Project-wide instructions for Claude when working in this Flutter repository.

---

## 1. Command Policy (STRICT — read this first)

### Never run without explicit permission

Do **not** run any of the following unless the user asks for it **in that message**, by name:

| Command | Status |
|---|---|
| `flutter test` / `dart test` | ❌ Never run unprompted |
| `flutter run` | ❌ Never run unprompted |
| `flutter build <any target>` | ❌ Never run unprompted |
| `flutter drive` / integration tests | ❌ Never run unprompted |
| `flutter emulators --launch` / any device launch | ❌ Never run unprompted |

Rules:

- Writing code is **not** permission to verify it by running it. Finish the code, then stop.
- "Make sure it works", "fix the bug", or "add a feature" does **not** authorize test/run/build.
- If you believe running something is necessary, **ask first in one line** and wait.
- Never work around this by invoking the same thing through another wrapper (`melos`, `fvm flutter test`, `make`, shell scripts, CI commands, IDE tasks). The restriction is on the action, not the spelling.
- After writing code, report what changed and state that tests/build were **not** run. Do not claim anything passed that you did not run.

### Always allowed (no need to ask)

- `flutter clean`
- `flutter pub get`, `flutter pub upgrade`, `flutter pub add/remove`
- `dart format`, `dart fix --apply`
- `flutter analyze` (static analysis only — this is not a build)
- `dart run build_runner build --delete-conflicting-outputs` (codegen for Hive adapters/json)
- All normal git work: `git status`, `git diff`, `git add`, `git commit`, `git log`, `git branch`, `git checkout`, `git push`

### Git conventions

- Never commit directly to `main`/`master` — branch first (`feat/…`, `fix/…`, `refactor/…`, `chore/…`).
- Conventional Commits: `feat(auth): add login cubit`, `fix(cart): handle empty cache`.
- One logical change per commit. Never commit generated junk, `.env`, keystores, or secrets.
- Do not `git push --force` on shared branches.

---

## 2. Architecture — Clean Architecture, feature-first

Folder layout (feature-first is the default for this repo):

```
lib/
├── core/
│   ├── di/                 # service locator / dependency wiring
│   ├── error/              # Failure, Exception types
│   ├── network/            # Dio client, interceptors, network info
│   ├── storage/            # Hive boxes setup, adapters registration
│   ├── router/             # route definitions
│   ├── theme/              # colors, text styles, app theme
│   ├── utils/              # extensions, formatters, validators
│   └── widgets/            # shared reusable widgets
│
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/    # <feature>_remote_datasource.dart (Dio)
│       │   │                   # <feature>_local_datasource.dart  (Hive)
│       │   ├── models/         # DTOs: fromJson/toJson, extends entity
│       │   └── repositories/   # <feature>_repository_impl.dart
│       ├── domain/
│       │   ├── entities/       # pure Dart, no annotations, no json
│       │   ├── repositories/   # abstract contracts only
│       │   └── usecases/       # one class, one `call()`
│       └── presentation/
│           ├── cubit/          # <feature>_cubit.dart, <feature>_state.dart
│           ├── pages/          # screens
│           └── widgets/        # widgets local to this feature
│
└── main.dart
```

### Dependency rule (non-negotiable)

```
presentation  →  domain  ←  data
```

- `domain` imports **nothing** from `data` or `presentation`, and no Flutter/Dio/Hive imports. Pure Dart only.
- `presentation` never touches a datasource, a model, or Dio/Hive directly — only usecases (via the cubit).
- `data` depends on `domain` (it implements its repository contracts).
- Repository implementations return `Either<Failure, Entity>` — never raw exceptions and never DTOs.

### Layer responsibilities

- **Entity** — pure business object, immutable, `Equatable`.
- **Model** — extends the entity, adds `fromJson`/`toJson` and Hive annotations. Models never leave the data layer.
- **Repository (domain)** — abstract class, returns `Future<Either<Failure, T>>`.
- **Repository impl (data)** — decides remote vs local (Hive cache), catches exceptions and maps them to `Failure`.
- **UseCase** — single responsibility, single public `call()` method, holds no state.
- **Cubit** — orchestrates usecases and emits states. No business logic, no HTTP, no direct storage.

---

## 3. State Management — Cubit (flutter_bloc)

- **Cubit only.** Do not introduce full `Bloc` with events, Provider, Riverpod, GetX, or `setState` for feature state.
- One cubit per feature (or per screen when a feature has clearly separate screens).
- State classes: sealed/abstract base + `Initial`, `Loading`, `Success(data)`, `Error(message)`. Use `Equatable` on every state.
- Never emit after `close()`; guard long async work with `if (isClosed) return;`.
- Cubits receive usecases via constructor injection — never construct dependencies inside a cubit.
- UI: `BlocBuilder` for rendering, `BlocListener` for one-off effects (snackbars, navigation), `BlocConsumer` when both are needed. Use `buildWhen`/`listenWhen` to avoid needless rebuilds.
- Provide cubits with `BlocProvider(create: (_) => sl<XCubit>())` at the narrowest scope that works.

---

## 4. Packages and how to use them

### Dio (network)

- A single configured `Dio` instance lives in `core/network/` — base URL, timeouts, interceptors. Never instantiate `Dio()` inside a feature.
- Auth token, logging, and error handling belong in interceptors, not in call sites.
- `DioException` is caught in the datasource or repository impl and converted into a `ServerFailure` / `NetworkFailure`. `DioException` must never reach a cubit or a widget.
- JSON parsing lives in models. Heavy parsing goes through `compute()`.

### Hive (local storage)

- Box opening and `registerAdapter` calls happen once at startup in `core/storage/`.
- Box names are constants in one place — no string literals scattered across the codebase.
- Only the local datasource touches Hive. Cubits and widgets never open a box.
- After changing a `@HiveType` class, run `build_runner` and keep `typeId` values stable and unique.
- Cache-first reads with a remote refresh are the default pattern for list screens unless the user says otherwise.

### flutter_bloc

- Version-pinned in `pubspec.yaml`. Use `BlocObserver` in debug for transition logging.

---

## 5. Code style

- `const` constructors everywhere possible; prefer `final` fields.
- Files: `snake_case.dart`. Classes: `PascalCase`. Members: `lowerCamelCase`; private members prefixed `_`.
- Widget build methods stay small — extract to private widget **classes**, not `Widget _buildX()` methods.
- No hardcoded strings, colors, or sizes in widgets — pull from `core/theme` and the localization layer.
- No `print` — use the project logger.
- Handle every `Either` branch: `fold(onFailure, onSuccess)`. Never `.right!` or force-unwrap.
- Dispose controllers, subscriptions, and focus nodes.
- Keep `analysis_options.yaml` rules satisfied; run `flutter analyze` after edits (this is allowed).

---

## 6. Working style

- Read the existing feature structure before adding a new one, and mirror its conventions.
- When adding a feature, create all layers in order: entity → repository contract → usecase → model → datasource → repository impl → cubit + state → UI → DI registration.
- Deliver complete files, not fragments.
- Do not add a dependency to `pubspec.yaml` without asking.
- Do not refactor unrelated code, rename files, or reformat whole files that weren't part of the task.
- If a requirement is ambiguous, ask one short question instead of guessing.
