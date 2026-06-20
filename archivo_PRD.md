# Archivo — Product Requirements Document

**Tagline:** Your Knowledge. Always With You.
**Document owner:** Product
**Status:** Draft v1.0
**Last updated:** June 20, 2026

---

## 1. Product Summary

Archivo is an **offline-first Personal Knowledge Vault** for Android. Users capture notes, files, links, and voice memos into a single private vault, organize them with folders and tags, and connect ideas through bi-directional `[[wiki-links]]` and a visual knowledge graph — fully functional with zero network dependency.

The vault is protected locally with biometric/PIN lock and encrypted at rest. There is no cloud sync in this version; everything lives on-device.

### 1.1 Problem Statement

Knowledge workers, students, and researchers scatter notes, screenshots, PDFs, links, and voice memos across five different apps, none of which talk to each other, and most of which require a live connection or a subscription to be useful. Archivo consolidates capture and retrieval into one private, fast, always-available vault.

### 1.2 Goals

- Let a user capture any kind of knowledge (text, file, link, voice) in under 5 seconds, from anywhere, with no network.
- Let a user find anything they saved in under 10 seconds via search, tags, folders, or the graph.
- Let a user see *connections* between their notes, not just a flat list.
- Guarantee privacy: local biometric lock + encryption at rest, no data leaves the device in v1.
- Ship an architecture (Flutter + BLoC) that scales cleanly into multi-platform, cloud sync, and collaboration without a rewrite.

### 1.3 Non-Goals (v1)

- Cloud sync / multi-device access
- Real-time collaboration / sharing vaults with others
- AI-generated summaries, semantic search, or auto-tagging
- Web or desktop clients
- Cloud transcription (voice transcription is on-device only)

---

## 2. Target Users

| Persona | Description | Primary Need |
|---|---|---|
| The Researcher | Grad student / analyst collecting sources, quotes, PDFs | Link ideas across sources; never lose a thought |
| The Builder | PM / founder / engineer capturing fragments of plans | Quick capture across formats; retrieve fast under pressure |
| The Privacy-Conscious Note-Taker | Doesn't trust cloud notes apps with personal data | Local-only storage, real encryption, no account required to start using |

---

## 3. Scope Tiers

Given the depth requested (multi-content capture + full bi-directional graph + on-device transcription, all offline, all in v1), this PRD splits scope into three tiers so the team can ship incrementally without re-planning architecture later.

| Tier | Contents | Why here |
|---|---|---|
| **MVP (Tier 0)** | Notes, files, links, voice; folders + tags; `[[wiki-links]]`; backlinks panel; graph view; biometric/PIN lock; encrypted local DB; on-device transcription | Core value proposition — capture + connect + retrieve, offline |
| **Fast-Follow (Tier 1)** | Cloud sync (Firebase Auth activates here), conflict resolution, multi-device, export/backup to cloud, full-text search ranking improvements | First version where Firebase Auth has a real job — see §4.6 |
| **Future (Tier 2)** | Collaboration/shared vaults, AI-assisted tagging & summarization, semantic search, web/desktop clients, plugin/extension system | Requires sync infrastructure and a backend service layer first |

This document specifies **Tier 0 (MVP)** in full, and gives architectural guardrails for Tier 1–2 in §9.

---

## 4. MVP Functional Requirements

### 4.1 Content Capture

Users can create four item types, each stored as a distinct content model but unified under a common `VaultItem` abstraction (id, title, createdAt, updatedAt, tags, folderId, linkedItemIds, isPinned, isArchived):

| Type | Capture method | Detail |
|---|---|---|
| **Note** | Rich-text editor | Markdown-backed; supports `[[wiki-link]]` autocomplete while typing |
| **File** | System file picker / share-intent from other apps | PDF, image, doc; stored copy in app-private encrypted storage; thumbnail generated |
| **Link** | Paste URL / share-intent from browser | Auto-fetches title + favicon when online; falls back to raw URL offline; user can annotate with a note |
| **Voice** | In-app recorder | Record → playback → **on-device transcription** runs after recording stops; transcript is editable and itself becomes searchable text attached to the item |

**Capture entry points:**
- Floating action button (FAB) on Vault Home → type picker
- Android Share Sheet integration (share a link, image, or file into Archivo from any app)
- Quick-capture widget (home screen) — Fast-Follow if not feasible in MVP timeline; flagged as **P1, not P0** (see §4.7)

### 4.2 Organization

- **Folders**: nestable, one folder per item (item can live in exactly one folder, or none/"Unsorted")
- **Tags**: many-to-many, freeform + autocomplete from existing tags
- **Wiki-links**: typing `[[` in any note body triggers autocomplete against existing item titles; selecting one creates a bi-directional link
- **Backlinks panel**: every item detail screen shows "Linked from" — all items that reference this one via `[[wiki-link]]`
- **Graph view**: full vault visualized as a force-directed node graph; nodes = items (colored/shaped by type), edges = wiki-links; tapping a node opens that item; pinch-zoom and pan supported

### 4.3 Search & Retrieval

- Global search bar (accessible from Vault Home) — full-text search across note bodies, file names, link titles/annotations, and voice transcripts
- Filter search results by type, tag, folder, date range
- Recent items list and Pinned items section on Vault Home

### 4.4 Security & Privacy

- **App lock**: biometric (fingerprint/face via Android BiometricPrompt) with PIN fallback, required on app open and configurable for "lock after X minutes idle"
- **Encryption at rest**: vault database encrypted using SQLCipher (or equivalent); encryption key derived from device keystore, never stored in plaintext
- **No network calls required** for any core function in MVP — app is fully usable in airplane mode, including transcription (on-device model)
- First-launch flow lets the user set up PIN/biometric before any data is created

### 4.5 Settings

- Manage app lock (change PIN, toggle biometric, auto-lock timer)
- Manage local backup/export (export vault to encrypted file the user can manually move — this is the only "backup" mechanism in MVP, since there is no cloud sync)
- Storage usage view (how much space the vault is using)
- About / version info

### 4.6 Authentication — Reconsidered

**Decision: No Firebase Auth in MVP.** Given there is no cloud sync to attach an account to, requiring email/Google sign-in at first launch would be friction with zero corresponding user benefit, and is a common reason for uninstall-before-first-use.

- **MVP**: No login screen at all. First launch goes straight into vault PIN/biometric setup (§4.4). The vault is the identity; there is no user account.
- **Fast-Follow (Tier 1)**: Firebase Auth (email + Google Sign-In, as originally planned) is introduced **at the moment cloud sync ships**, framed to the user as "Back up & sync your vault." This is also when the existing local-only vault is migrated/encrypted-uploaded to Firestore/Cloud Storage.
- The codebase should still scaffold an `AuthRepository` interface now (see §9.2) so this slots in later without restructuring the data layer.

### 4.7 Feature Prioritization Inside MVP

To keep "MVP" honest, within Tier 0 itself:

**P0 (cannot ship without):**
Notes, files, links, voice+transcription, folders, tags, wiki-links, backlinks panel, basic graph view, search, biometric/PIN lock, encryption at rest.

**P1 (ship if timeline allows, else immediate post-launch patch):**
Graph view advanced interactions (filtering graph by tag/type), home-screen quick-capture widget, local encrypted export/backup.

---

## 5. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Performance | Vault Home loads in <500ms with up to 5,000 items; graph view renders smoothly up to ~1,000 nodes |
| Offline | 100% of P0 features function with no network connection |
| Storage | All user content stored in app-private storage; no external/shared storage writes without explicit export action |
| Transcription | On-device model runtime adds reasonable APK size (~tens of MB); document size cost in build planning |
| Accessibility | Support Android system font scaling and TalkBack for core navigation flows |
| Device support | Android 8.0 (API 26)+ recommended floor — confirm against chosen on-device transcription SDK's minimum supported API level |

---

## 6. Information Architecture (Screen Inventory)

This is the full MVP screen list — used 1:1 as the spec for `design.md`:

1. Splash / Launch
2. Onboarding (3 slides: capture anything, connect ideas, fully private)
3. Vault Setup (create PIN + optional biometric enrollment)
4. Lock Screen (biometric/PIN entry, shown on every app open after setup)
5. Vault Home (recent + pinned items, FAB, search bar entry, bottom nav)
6. Search Results (with filter chips)
7. Folder List / Folder Detail
8. Tag List / Tag Detail (items under a tag)
9. Capture Type Picker (FAB menu: Note / File / Link / Voice)
10. Note Editor (create/edit, with `[[` autocomplete)
11. File Item Add Flow (picker → preview → tag/folder assign)
12. Link Item Add Flow (paste/share → fetched preview → annotate)
13. Voice Recorder (record → stop → transcribing state → transcript review/edit)
14. Item Detail (generic shell adapting per type: note body / file preview / link card / audio player+transcript) with Backlinks panel
15. Graph View (full vault graph, zoom/pan, tap-to-open)
16. Settings (Home)
17. Settings → App Lock
18. Settings → Backup & Export
19. Settings → Storage
20. Settings → About

---

## 7. Brand & Visual Direction (for design.md handoff)

Visual identity is locked to the existing app icon and feature banner (assets provided), establishing:

- **Primary brand color**: Deep indigo `#303094`
- **Accent color**: Warm gold `#E3BF75`
- **Tone**: Clean, confident, slightly playful (rounded shapes, soft shadows, the "gift box revealing a glowing document" motif = "your knowledge, unboxed")
- Full token-level detail is specified in the companion `design.md`.

---

## 8. Tech Stack — MVP

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter (latest stable) | Single codebase, Android-first for v1 |
| State management | **flutter_bloc** | See §9.1 for module structure |
| Local database | **Drift** (SQL, type-safe) or Isar, wrapped with **SQLCipher** for encryption at rest | Drift recommended for relational integrity across items/tags/folders/links |
| File storage | App-private directory (`getApplicationDocumentsDirectory`), files encrypted or stored in an encrypted container | |
| Voice transcription | On-device ASR (e.g., platform Speech-to-Text offline model, or a bundled Whisper-tiny/small variant) | Final SDK choice should be validated against APK size budget and Android offline-mode support |
| Biometric/PIN | `local_auth` plugin + secure key storage via Android Keystore | |
| Graph rendering | Custom Flutter `CustomPainter` / force-directed layout package | Must support pan/zoom and reasonable performance at MVP node-count targets |
| Dependency injection | `get_it` (or `injectable`) paired with BLoC | Keeps repositories swappable for Tier 1 (local → local+remote) |

---

## 9. Architecture for Future Scaling

The MVP must be built so that Tier 1 (sync) and Tier 2 (collaboration/AI/multi-platform) are **additive**, not rewrites. Two principles drive this:

### 9.1 BLoC Module Structure

Organize by **feature-first folders**, each with its own `bloc/`, `repository/`, `models/`, `view/`:

```
lib/
  core/
    theme/              # design tokens from design.md, shared across features
    di/                 # get_it service locator setup
    encryption/         # SQLCipher key mgmt, keystore wrapper
    routing/
  features/
    onboarding/
    vault_lock/         # PIN/biometric — isolated so Tier 1 auth can sit beside it, not replace it
    vault_home/
    capture/
      note/
      file/
      link/
      voice/
    organization/
      folders/
      tags/
    graph/
    search/
    settings/
      backup_export/
  shared/
    widgets/            # design-system components (buttons, cards, item tiles)
    models/             # VaultItem and shared domain models
```

Each feature's BLoC talks **only to its repository interface**, never directly to Drift/SQLCipher. This is the seam that makes Tier 1 possible.

### 9.2 Repository Abstraction (the key scaling seam)

Every data-touching feature defines a repository **interface** in MVP, with a **local-only implementation**:

```dart
abstract class VaultItemRepository {
  Future<List<VaultItem>> getAll();
  Future<VaultItem> getById(String id);
  Future<void> save(VaultItem item);
  Future<void> delete(String id);
  Stream<List<VaultItem>> watchAll(); // for reactive BLoC state
}

class LocalVaultItemRepository implements VaultItemRepository {
  // Drift/SQLCipher implementation — MVP ships only this
}
```

**In Tier 1**, a `SyncedVaultItemRepository` is introduced that wraps the local repository and adds a remote data source (Firestore), implementing conflict resolution and queued writes for offline-then-sync behavior — **without changing a single BLoC**, because BLoCs only know the interface. `AuthRepository` is scaffolded the same way now, with a `NoOpAuthRepository` in MVP and a `FirebaseAuthRepository` swapped in at Tier 1.

### 9.3 Data Model Considerations for Sync

Even though MVP has no sync, design the local schema now to avoid painful migration later:

- Every `VaultItem` gets a stable UUID (not autoincrement int) — required for any future multi-device merge.
- Include `updatedAt` (already in MVP model) and reserve a `syncStatus` enum field now (`local`, `pendingSync`, `synced`) even if unused until Tier 1 — avoids a schema migration just to add sync bookkeeping.
- Wiki-links should be stored as a separate join table (`item_links: fromId, toId`) rather than embedded in note text parsing alone, so the graph and backlinks queries stay fast and are trivially syncable later.

### 9.4 Tier 1 / Tier 2 Preview (non-binding, directional)

| Tier 1 (Sync) | Tier 2 (Collaboration / AI / Multi-platform) |
|---|---|
| Firebase Auth (email + Google) activated | Shared vaults with permissions (owner/editor/viewer) |
| Firestore + Cloud Storage as remote data source behind existing repository interfaces | Realtime presence/collaboration on shared notes |
| Background sync worker, conflict resolution UI | Semantic search / AI-assisted tagging (likely via a backend LLM service, not on-device) |
| Encrypted backup restore across devices | Web client (Flutter Web) and/or desktop, reusing the same BLoC/repository layer |
| | Plugin/extension architecture for third-party integrations |

---

## 10. Open Questions / Risks

- **On-device transcription model choice** materially affects APK size, supported languages, and accuracy — needs a spike before committing to a specific SDK.
- **Graph performance** at scale (thousands of nodes) may need clustering/level-of-detail rendering; flagged for design + engineering review before Tier 0 sign-off.
- **No backup in MVP beyond manual export** means uninstalling the app loses all data unless the user manually exported — this should be surfaced clearly in onboarding/settings copy, not hidden.
- **Voice transcription accuracy offline** will be lower than cloud ASR; set user expectations in-product (editable transcript, not presented as perfect).

---

## 11. Success Metrics (MVP)

- % of new users who create at least 3 vault items within first session
- % of users who create at least 1 wiki-link within first week
- D7 retention
- Average items captured per active user per week
- Crash-free session rate (target ≥99.5%, given offline reliability is core to the value prop)
