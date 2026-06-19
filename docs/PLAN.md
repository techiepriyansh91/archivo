# archivo — Execution Plan (depth-first)

A Personal Knowledge Vault built to demonstrate senior Flutter engineering. The
goal is **depth on hard problems**, not feature count. Build order is:
**Notes (perfectly) → Sync engine (deeply) → everything else (fast).**

Stack decisions (locked):
- **Local DB:** Drift (SQLite) — see §2
- **Sync:** full sync queue + conflict resolution — see §4
- **Auth:** Firebase email/password + Google sign-in, required at first launch =
  canonical owner uid; secure-storage session persistence on top — see §3.1
- **Conflicts:** 3-way field merge for notes; row-level LWW for tags/collections — see §4.3
- **State:** Cubit by default, full Bloc only where an event stream earns it

---

## 1. Folder structure (Clean Architecture)

Feature-first. Each feature has its own `data / domain / presentation`. Shared
infra lives in `core/`. Wiring lives in `injection/`.

```
lib/
├── core/
│   ├── database/          # Drift AppDatabase, DAOs, migrations
│   ├── error/             # Failure, Exception types, Either helpers
│   ├── network/           # connectivity, Firestore client wrapper
│   ├── sync/              # SyncEngine, SyncQueue, conflict resolver (cross-feature)
│   ├── theme/
│   ├── usecase/           # UseCase<Type, Params> base
│   └── utils/             # debouncer, id gen (uuid v4), clock
│
├── features/
│   ├── auth/
│   │   ├── data/          # repo impl, secure storage datasource
│   │   ├── domain/        # entities, repo interface, usecases
│   │   └── presentation/  # cubit, pages, widgets
│   ├── notes/
│   ├── search/
│   ├── tags/
│   ├── collections/
│   └── settings/
│
├── injection/             # get_it + injectable container
├── app.dart               # MaterialApp, router, theme, top-level BlocProviders
└── main_<flavor>.dart     # entrypoints: main_dev / main_staging / main_prod
```

**Dependency rule:** `presentation → domain ← data`. Domain depends on nothing
(pure Dart, no Flutter, no Drift). Repositories are interfaces in `domain/`,
implemented in `data/`. This is what lets you unit-test use cases with fakes.

### Layer responsibilities (the part interviewers probe)
- **Entity** (domain): pure business object. No JSON, no Drift annotations.
- **Model/DTO** (data): maps DB rows ↔ entities and Firestore docs ↔ entities.
  Keep mapping in extension methods, not in the entity.
- **UseCase** (domain): one public `call()`, single responsibility. e.g.
  `CreateNote`, `WatchNotes`, `SyncNow`.
- **Repository interface** (domain) vs **impl** (data): impl decides DB-first,
  enqueues sync ops, never leaks Drift/Firestore types upward.

---

## 2. Why Drift over Isar (decision record)

| Need | Drift (SQLite) | Isar |
|---|---|---|
| Full-text search | FTS5 virtual table (real ranked search) | built-in index (good, less control) |
| Many-to-many tags | join table + SQL JOIN (textbook) | object links |
| Migrations story | explicit, versioned, demonstrable | schema-managed, less to show |
| Interview signal | "I write SQL + handle migrations" | "I used a fast NoSQL embed" |

Drift wins **for this app** because tags (M:N), collections (1:N), and ranked
full-text search are exactly what SQL + FTS5 model cleanly — and because explicit
migrations are a senior talking point. Isar would be faster to build but gives you
less to defend in an interview. Record this tradeoff in your README.

---

## 3. Data model

### 3.1 Sync metadata on every syncable row
Every user-owned row carries these columns from day one (cheap now, painful to
retrofit):

```
id            TEXT  PRIMARY KEY     -- uuid v4, client-generated (offline-safe)
user_id       TEXT                  -- Firebase uid, owner (see identity note below)
updated_at    INT                   -- epoch ms, set on every write (LWW clock)
deleted_at    INT?                  -- soft delete = tombstone (sync can propagate)
sync_status   INT                   -- 0 synced, 1 pending, 2 conflict
remote_rev    TEXT?                 -- server revision/etag for conflict detection
base_json     TEXT?                 -- notes only: last-synced snapshot for 3-way merge (§4.3)
```

**Identity (decision):** require **Firebase email/password + Google sign-in at
first launch**; that uid owns every row from the first write. It is a real,
server-recognized id, so Firestore rules (`request.auth.uid == userId`) enforce
ownership — and because login happens *before* any data is created, there is no
backfill and no anonymous→link flow to build. Everything sits behind an
`AuthRepository` so the rest of the app never touches Firebase directly; the data
and sync layers only ever read `currentUser.uid`. First launch needs connectivity
to sign in; the session is then cached in secure storage and the uid is stable
offline. (Anonymous-auth + credential-linking is the pattern *if* you later want
try-before-signup — treat it as optional polish, not the default.)

Google sign-in setup: add `google_sign_in`, register SHA-1/SHA-256 fingerprints
in each of archivo-dev / staging / prod, and enable the Google provider per project.

Generating row ids on the client (uuid) is mandatory for offline-first — never
depend on a server for a primary key.

### 3.2 Tables
```
notes(id, title, body, is_favorite, is_archived, collection_id?, + sync cols)
tags(id, name, color, + sync cols)
note_tags(note_id, tag_id)                 -- M:N join table, composite PK
collections(id, name, icon, + sync cols)   -- 1:N: a note has one collection
notes_fts                                  -- FTS5(title, body) mirror of notes
sync_queue(id, entity_type, entity_id, op, payload, attempts, next_attempt_at, created_at)
```

`notes_fts` is kept in sync with `notes` via triggers (INSERT/UPDATE/DELETE), so
search never goes stale. DAOs expose `Stream` queries (`watch...`) so the UI is
reactive — Drift rebuilds streams when underlying tables change.

---

## 4. Sync engine — the headline feature

This is where you spend real depth. Architecture: **local DB is the source of
truth; sync is a background reconciliation process.** The UI never waits on the
network.

### 4.1 Write path (offline-first)
1. UseCase writes to Drift (sets `updated_at = now`, `sync_status = pending`).
2. Same transaction enqueues a row in `sync_queue` (op = create/update/delete,
   carries entity id + minimal payload). **One transaction** so DB and queue can't
   diverge.
3. UI updates instantly from the Drift stream (optimistic — no spinner).

### 4.2 Sync loop
A `SyncEngine` triggered by: app start, connectivity-regained, manual pull-to-
refresh, and a periodic timer. It:
1. **Push:** drains `sync_queue` oldest-first, idempotently. Each op sends
   `updated_at` + `remote_rev`. On success → `sync_status = synced`, dequeue. On
   failure → bump `attempts`, set `next_attempt_at` with exponential backoff
   (e.g. 2^n capped). Network calls must be **idempotent** (use the row id as the
   Firestore doc id) so a retry after a partial failure is safe.
2. **Pull:** fetch remote docs changed since `lastPulledAt` cursor; feed each
   through the conflict resolver; apply; advance cursor.

### 4.3 Conflict resolution (3-way merge for notes, LWW elsewhere)
On pull, for each remote doc vs local row:
- local not present → insert.
- remote `deleted_at` set → apply tombstone locally.
- delete-vs-update → **tombstone wins** (deletes propagate) — state this explicitly.
- both changed (local `sync_status = pending` AND remote newer) → resolve by entity:

**Notes → 3-way field merge (git-style).** This is the deliberate choice: a note's
`body` is a large free-text asset that must not be silently lost. Keep the
last-synced snapshot in `base_json`. For each field, compare local vs remote vs base:
  - only one side differs from base → take that side (no loss — e.g. title edited
    on phone, body edited on tablet both survive).
  - both sides differ from base on the *same* field → fall back to **LWW by
    `updated_at`** for that field (deterministic tiebreak).
  - after merge, clear `base_json`, set `sync_status = synced`, re-enqueue if the
    merged result differs from remote.

**Tags / collections → row-level LWW by `updated_at`.** Small rows, no free-text
asset; 3-way merge would be wasted complexity. Keep it simple and defend the
asymmetry — matching the policy to the data is itself a senior signal.

Optionally mark `sync_status = conflict` to surface a "review" UI; not required.

> Why not CRDTs/OT? This is single-user multi-device, not real-time collaboration.
> True concurrent same-field edits are rare; 3-way merge handles the common case
> (different fields) losslessly and degrades gracefully. CRDTs would be over-built.

### 4.4 What to be ready to explain in interviews
- "Two devices edit *different fields* of one note offline" → 3-way merge keeps
  both; only same-field edits fall back to LWW by `updated_at`.
- "Why 3-way merge for notes but LWW for tags?" → match the policy to the data:
  notes hold a free-text body you can't lose; tags don't. Avoid CRDTs — single-user
  multi-device, not collaboration.
- "Why require login before any data exists?" → guarantees every row has a real
  uid owner from the first write, so Firestore rules enforce ownership and there's
  no backfill — login-first is the simpler, safer design for a synced app.
- "Sync fails mid-batch" → queue is durable in SQLite, retried with backoff;
  ops idempotent via stable ids, so partial application is safe.
- "Why client-generated ids?" → offline create must not block on a server.
- "Why a queue table instead of just a dirty flag?" → preserves operation order
  and survives app kill; a flag loses the sequence of edits.

---

## 5. Build order (depth-first slices)

Ship something working at the end of **each** slice. Do not start a slice before
the previous one is green in CI.

**Slice 0 — Skeleton (½ day)**
git init · folder structure · get_it/injectable · Drift `AppDatabase` with one
table · one `flutter_test` passing · GitHub Actions running analyze+test.

**Slice 1 — Identity + Notes, perfectly (the quality bar for everything else)**
Firebase email/password + Google sign-in behind `AuthRepository` (uid + secure-
storage session), with login required before the app shell loads — so every row is
owned by a real uid from the first write. Then the full Notes vertical: entity →
repo interface → Drift DAO + repo impl → use cases
(create/update/delete/archive/watch) → NotesCubit → list + editor UI.
Tests: use case unit tests with a fake repo, repo impl test against in-memory
Drift, fake AuthRepository, one widget test for the list. **This slice defines
your standard.**

**Slice 2 — Sync engine (your headline — go deep, §4)**
uid already exists from Slice 1. Build sync_queue, SyncEngine push/pull, and the
conflict resolver (3-way merge for notes, LWW for tags/collections). Test the
resolver hard with table-driven unit tests: local-only, remote-only, different-
fields, same-field, delete-vs-update.

**Slice 3 — Tags, collections, search (cheap once arch exists)**
M:N tags (+ filter), 1:N collections, FTS5 search with a 300ms debouncer.
Favorites = a boolean + optimistic toggle. These reuse Slice 1's pattern.

**Slice 4 — Polish / optional senior flair**
Analytics dashboard (aggregate queries), export (JSON/Markdown/PDF), backup-
restore, local notifications. Pick based on time; none are load-bearing.

---

## 6. Testing strategy (concrete targets)

- **Unit (domain):** every use case with a mocked repo (mocktail). Fast, no I/O.
- **Data:** repo impls against **in-memory Drift** (`NativeDatabase.memory()`).
  Real SQL, no mocks — proves your queries and migrations actually work.
- **Conflict resolver:** pure-function, table-driven tests covering every branch
  in §4.3. This is your highest-value test suite.
- **Cubit:** `bloc_test` for state transitions (loading → loaded → error).
- **Widget:** smoke test list + editor with a fake cubit.
- **Migration test:** open DB at v1, migrate to v2, assert data survives.
- Aim coverage where it matters (domain + sync), not 100% of UI.

---

## 7. CI/CD + flavors

You already have `archivo-dev / archivo-staging / archivo-prod` Firebase projects.

**Flavors** (Android product flavors + iOS schemes / xcconfig):
```
dev      → app id .dev      → google-services (archivo-dev)      → "archivo Dev"
staging  → app id .staging  → google-services (archivo-staging)  → "archivo Staging"
prod     → app id           → google-services (archivo-prod)     → "archivo"
```
Entrypoints: `main_dev.dart` / `main_staging.dart` / `main_prod.dart`, each
injecting a flavor-specific `AppConfig` (Firebase options, API base, flags).

**GitHub Actions** (`.github/workflows/ci.yml`):
```
on push/PR:
  - flutter analyze
  - flutter test --coverage
  - build APK (dev flavor on PRs)
branch → flavor mapping:
  develop → dev build (artifact)
  staging → staging build (internal testers)
  main    → prod build (AAB, signed, upload artifact)
```
Keep signing keys + google-services files out of git; inject via Actions secrets.

---

## 8. First commands

```bash
git init && git add -A && git commit -m "chore: flutter create baseline"
# then Slice 0: add drift, get_it, injectable, freezed, mocktail, bloc, uuid
```

Suggested initial deps: `drift`, `sqlite3_flutter_libs`, `flutter_bloc`,
`get_it`, `injectable`, `freezed`/`json_serializable`, `uuid`,
`connectivity_plus`, `flutter_secure_storage`, `firebase_core`, `firebase_auth`,
`google_sign_in`, `cloud_firestore`; dev: `drift_dev`, `build_runner`,
`mocktail`, `bloc_test`, `injectable_generator`.
