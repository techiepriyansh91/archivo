# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Note: a `CLAUDE.md` for a different project ("Mocyfy") lives in the parent `Desktop/` folder. It does **not** apply here — archivo is a Flutter app, not a Next.js one. Ignore it.

## What this is

archivo is an offline-first **Personal Knowledge Vault** (notes, tags, collections, full-text search) built to demonstrate senior Flutter engineering. The guiding principle is **depth on hard problems over feature count**. The headline feature is the sync engine. Build order: **Notes (perfectly) → Sync engine (deeply) → everything else (fast)**. The full design rationale and roadmap live in [docs/PLAN.md](docs/PLAN.md) — read it before making architectural changes.

## Commands

```bash
flutter pub get                                          # install deps
dart run build_runner build --delete-conflicting-outputs # REQUIRED after touching Drift tables/DAOs
dart run build_runner watch --delete-conflicting-outputs # rerun codegen on save
dart format .                                            # format (CI fails if not formatted)
flutter analyze                                          # static analysis (must be clean)
flutter test                                             # all tests
flutter test test/features/notes/domain/usecases/create_note_test.dart  # single file
flutter test --name "creates a note"                     # single test by name
flutter run                                              # run the app
```

**Codegen is not optional.** `*.g.dart` files (`app_database.g.dart`, `notes_dao.g.dart`) are generated and git-ignored-adjacent build artifacts. Any change to a Drift `Table` or `@DriftAccessor` DAO requires rerunning `build_runner`, or analyze/tests will fail against stale generated code. CI regenerates them, so a forgotten regen surfaces as a CI failure.

CI ([.github/workflows/ci.yml](.github/workflows/ci.yml)) runs on every push/PR and gates on, in order: `pub get` → `build_runner build` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`. All must pass. Pinned to Flutter `3.38.3` stable.

## Architecture

**Clean Architecture, feature-first.** Each feature under `lib/features/<feature>/` has three layers; shared infra is in `lib/core/`; wiring is in `lib/injection/`.

```
lib/
├── core/           database (Drift) · error (Failure) · sync · usecase · utils (Clock) · network · theme
├── features/<f>/
│   ├── domain/     entities · repository *interfaces* · usecases   (pure Dart — no Flutter, no Drift, no Firebase)
│   ├── data/       repository impls · DAOs · mappers               (Drift + Firebase live here)
│   └── presentation/ cubits + states · pages · widgets
├── injection/      get_it service locator (configureDependencies)
├── app.dart        MaterialApp + top-level BlocProviders
└── main.dart       Firebase.initializeApp → configureDependencies → runApp
```

**Dependency rule (enforced by discipline, watch for violations):** `presentation → domain ← data`. The domain layer depends on nothing — no Flutter, no Drift, no Firebase imports there. Repository interfaces live in `domain/repositories/`; implementations live in `data/`.

### Key cross-cutting patterns

- **Offline-first, local DB is source of truth.** Repository writes go to Drift first and set `syncStatus = pending`; the UI updates instantly from a Drift `Stream` (no spinner). Network sync is a separate background reconciliation process that never blocks the UI. See [docs/PLAN.md](docs/PLAN.md) §4.
- **Sync metadata on every syncable row, from day one.** Every user-owned table carries `id` (client-generated uuid v4), `userId` (Firebase uid owner), `updatedAt` (epoch ms, LWW clock), `deletedAt` (soft-delete tombstone), `syncStatus` (0 synced / 1 pending / 2 conflict), `remoteRev`, and — notes only — `baseJson` (last-synced snapshot for 3-way merge). See [app_database.dart](lib/core/database/app_database.dart) and PLAN §3.1. **Do not strip these when adding tables.**
- **Reactive DAOs.** DAOs expose `watch...()` `Stream` queries so Drift rebuilds the UI when tables change. Repositories map `NoteRow` (Drift row class) → `Note` (domain entity) via extension mappers in `data/mappers/`; the generated row class is named `NoteRow` to avoid clashing with the entity.
- **Failure boundary.** Data-layer exceptions (Drift/Firebase) are caught at the repository boundary and rethrown as a typed [Failure](lib/core/error/failure.dart) (`DatabaseFailure`, `NetworkFailure`, `AuthFailure`, `SyncFailure`). Use cases and cubits only ever see `Failure`, never raw Drift/Firebase types. Cubits catch `Failure` and map to an error state.
- **Auth boundary.** All Firebase auth goes through `AuthRepository`; the rest of the app only reads `currentUser.uid`. Login is required at first launch (`AuthGate` in `app.dart`), so every row has a real owner uid from its first write — no anonymous→link backfill. The `AuthCubit` is a single app-lifetime singleton provided above `MaterialApp`.
- **Conflict resolution (planned, Slice 2).** Notes use a **3-way field merge** (keep `baseJson`, merge per-field, LWW tiebreak on same-field conflicts); tags/collections use **row-level LWW**. The conflict resolver is intended to be a pure function — the highest-value test target. See PLAN §4.3.

### Dependency injection

`lib/injection/injection.dart` uses **get_it manually** (`registerLazySingleton` / `registerFactory`). `injectable` is a dependency but codegen is not wired up yet — the plan is to migrate once the graph grows. Add new registrations to `configureDependencies()`. Singletons: `AppDatabase`, `Clock`, `Uuid`, `FirebaseAuth`, repositories, `AuthCubit`. Factories: use cases and feature cubits.

### Use cases

Every business operation is a `UseCase<T, Params>` ([usecase.dart](lib/core/usecase/usecase.dart)) with one public `call()`. Use `NoParams` for argument-less ones. One use case = one responsibility (`CreateNote`, `WatchNotes`, etc.).

## Testing

- **Domain use cases:** mock the repo with `mocktail`. Fast, no I/O.
- **Data / repo impls:** real in-memory Drift via `NativeDatabase.memory()` (pass an executor to `AppDatabase(...)`) — no mocking the DB, proves queries actually work.
- **Cubits:** `bloc_test` for state transitions.
- **Conflict resolver (when built):** pure-function, table-driven tests covering every branch — the most important suite.
- Shared fakes live in [test/helpers/test_doubles.dart](test/helpers/test_doubles.dart). Test tree mirrors `lib/`.

## Conventions

- **State management:** Cubit by default; reach for full Bloc only where an event stream genuinely earns it.
- **IDs:** always client-generated `uuid` v4 — offline create must never wait on a server.
- **Time:** never call `DateTime.now()` directly in repos; inject `Clock` ([clock.dart](lib/core/utils/clock.dart)) and use `nowMs()` so it's testable.
- **Deletes:** soft-delete (set `deletedAt`) so the tombstone can propagate through sync — never hard-delete syncable rows.
- **Drift version pinning:** `drift`/`drift_dev` are pinned to `>=2.31.0 <2.32.0` deliberately. sqlite3 3.x ships a native build hook that the current `build_runner` can't bootstrap. Bump both together only when build_runner gains build-hook support (see pubspec comment + PLAN).
- Lints: `flutter_lints` via [analysis_options.yaml](analysis_options.yaml).
