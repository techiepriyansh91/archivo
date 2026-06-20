# Archivo — Design System & Screen Specifications

**Purpose:** This document is the design handoff spec for generating MVP screens (e.g., via Stitch). All colors below were sampled directly from the provided app icon (`archivo_icon_512_final.png`) and feature banner (`archivo_feature_banner_final.png`) — do not substitute approximate or "similar" colors.

---

## 1. Brand Foundation

**Concept:** An open gift box revealing a glowing document with a sparkle — "your knowledge, unboxed." Clean, geometric, confident, warm. Rounded corners throughout (the app icon itself uses a superellipse/squircle mask).

**Logo lockup:** Icon (box + document) to the left, wordmark/tagline to the right — as shown in the feature banner: "Your Knowledge. Always With You."

---

## 2. Color Tokens

All hex values below are sampled directly from source assets (not estimated).

### 2.1 Core Palette

| Token | Hex | Sampled from | Usage |
|---|---|---|---|
| `color/primary` | `#303094` | Icon background (dominant fill) | App bars, primary buttons, FAB, active nav states, lock screen background |
| `color/primary-dark` | `#252570` | Derived (−15% luminance of primary) | Pressed states, status bar overlay |
| `color/accent-gold` | `#E3BF75` | Box lid / sparkle highlight | Secondary actions, highlights, selected tags, graph node accents, badges |
| `color/accent-gold-dark` | `#C9A65E` | Derived (box shadow face, darker gold) | Gold-on-gold borders, pressed accent states |
| `color/surface-white` | `#FFFFFF` | Document / box interior | Cards, sheets, input fields, light-mode background |
| `color/ink` | `#1A1A2E` | Derived near-black with indigo undertone | Primary text on light surfaces |

### 2.2 Functional / Neutral Palette (derived, for full UI coverage)

| Token | Hex | Usage |
|---|---|---|
| `color/background` | `#F7F6F2` | Screen background (warm off-white, complements gold) |
| `color/surface-elevated` | `#FFFFFF` | Cards, modals, bottom sheets |
| `color/border` | `#E5E2D9` | Dividers, input borders, card outlines |
| `color/text-primary` | `#1A1A2E` | Headlines, body text |
| `color/text-secondary` | `#6B6B80` | Captions, metadata, timestamps |
| `color/text-on-primary` | `#FFFFFF` | Text/icons on indigo surfaces |
| `color/text-on-gold` | `#1A1A2E` | Text/icons on gold surfaces (gold is light enough to need dark text) |
| `color/success` | `#3FA66B` | Save confirmations, sync-ready states (future) |
| `color/error` | `#D64545` | Validation errors, destructive action confirmation |
| `color/warning` | `#E3A23C` | Storage warnings, low-confidence transcription notice |

### 2.3 Content-Type Accent Colors (for item tiles, graph nodes, badges)

Derived from the core palette to stay on-brand while distinguishing the four capture types at a glance:

| Type | Token | Hex | Notes |
|---|---|---|---|
| Note | `color/type-note` | `#303094` (primary) | Default brand color |
| File | `color/type-file` | `#5C5CAE` | Lighter indigo tint |
| Link | `color/type-link` | `#7B7BC4` | Even lighter indigo tint |
| Voice | `color/type-voice` | `#E3BF75` (accent-gold) | Gold, the "warmest" type, pairs with waveform iconography |

### 2.4 Dark Mode (future-ready, not required for MVP build but specify for design consistency)

| Token | Hex |
|---|---|
| `color/background-dark` | `#15152A` |
| `color/surface-dark` | `#1F1F3D` |
| `color/text-primary-dark` | `#F0EFEA` |

---

## 3. Typography

No custom typeface was supplied in assets; banner wordmark uses a clean rounded-sans grotesque (bold weight). Recommended system-safe equivalent:

- **Primary typeface:** `Inter` (or system default `Roboto` if Inter unavailable in target tool) — matches the geometric, rounded-but-confident character of the banner wordmark.
- **Scale:**

| Token | Size / Weight | Usage |
|---|---|---|
| `type/display` | 28sp / Bold | Onboarding headlines |
| `type/h1` | 22sp / Bold | Screen titles (Vault Home, Settings) |
| `type/h2` | 18sp / SemiBold | Section headers, item detail titles |
| `type/body` | 15sp / Regular | Note body, descriptions |
| `type/body-strong` | 15sp / SemiBold | Item titles in lists |
| `type/caption` | 12sp / Regular | Timestamps, metadata, tag labels |
| `type/button` | 15sp / SemiBold | Button labels |

---

## 4. Shape, Elevation, Iconography

- **Corner radius:** `16dp` for cards/sheets, `12dp` for buttons/inputs, `28dp` (squircle-like, matching the icon mask) for the FAB and app icon-style elements.
- **Elevation:** Soft, warm-toned shadows (not pure black) — `rgba(48,48,148,0.12)` for resting cards, `rgba(48,48,148,0.20)` for elevated/floating elements (FAB, modals). This echoes the soft shadow under the box in the icon.
- **Iconography style:** Rounded-stroke, 2dp stroke weight, matching the soft geometric style of the box/document icon. Use filled icons for active/selected nav states, outlined for inactive.
- **Motif reuse:** The sparkle (✦) from the icon can be used as a small decorative accent for empty states, "new item created" confirmations, and the onboarding screen about connecting ideas.

---

## 5. Component Tokens

| Component | Spec |
|---|---|
| **Primary button** | Fill `color/primary`, text `color/text-on-primary`, radius `12dp`, height `48dp` |
| **Secondary/accent button** | Fill `color/accent-gold`, text `color/text-on-gold`, radius `12dp` |
| **FAB (capture button)** | `color/primary` fill, `color/accent-gold` "+" icon or sparkle icon, `28dp` radius, elevated shadow |
| **Item tile (list)** | White card, `16dp` radius, left edge 4dp color strip in the item's type-accent color, title in `type/body-strong`, metadata in `type/caption` + `color/text-secondary` |
| **Tag chip** | Pill shape, `color/accent-gold` at 20% opacity fill, `color/accent-gold-dark` text/border |
| **Input field** | White fill, `1dp` border `color/border`, `12dp` radius, focus state border becomes `color/primary` 2dp |
| **Bottom nav** | White background, active icon+label in `color/primary`, inactive in `color/text-secondary` |
| **Graph node** | Circle, fill = type-accent color, size scales gently with number of connections, label appears on tap/zoom |
| **Graph edge** | `1.5dp` line, `color/border` at rest, `color/accent-gold` when connected node is selected |

---

## 6. Screen Specifications

Each screen below should be generated at standard Android mobile viewport. All screens use `color/background` (`#F7F6F2`) as the base canvas unless noted.

---

### 6.1 Splash / Launch
- Full-bleed `color/primary` (`#303094`) background.
- Centered app icon motif (box + document + sparkle) at large scale.
- App name "Archivo" in white, `type/display`, below icon.
- No interactive elements; auto-transitions after brief delay.

### 6.2 Onboarding (3 slides, swipeable)
- White/`background` canvas, illustration area top 60%, text bottom 40%.
- Slide 1: "Capture anything." Illustration: note/file/link/mic icons converging into the box icon. Sparkle accent.
- Slide 2: "Connect your ideas." Illustration: simplified graph/node visualization in primary + gold.
- Slide 3: "Always private, always offline." Illustration: box with a lock motif, indigo + gold.
- Bottom: page indicator dots (`color/primary` active, `color/border` inactive), "Skip" text button top-right, "Next"/"Get Started" primary button bottom.

### 6.3 Vault Setup (PIN + Biometric Enrollment)
- `color/background` canvas, centered content.
- Headline: "Protect your vault" (`type/h1`).
- Subtext: explains local-only encryption in plain language.
- 6-digit PIN entry (dot indicators filling in as typed, `color/primary`).
- Below: toggle/card "Enable fingerprint/face unlock" with relevant icon, `color/accent-gold` accent when enabled.
- Primary button: "Continue."

### 6.4 Lock Screen
- `color/primary` full-bleed background (echoes splash, reinforces brand on every app open).
- Centered: app icon (small), "Archivo" wordmark, biometric prompt icon (fingerprint), text "Touch sensor to unlock" or auto-triggered system biometric sheet.
- "Use PIN instead" text link below in white/70% opacity.
- PIN entry state: numeric keypad, dot indicators, white-on-indigo styling with gold accent on active dot.

### 6.5 Vault Home
- App bar: `color/primary` background, "Archivo" wordmark left, search icon + settings icon right.
- Search bar (tappable, leads to Search Results) directly below app bar, white pill on `background`.
- "Pinned" horizontal scroll section (item tiles), shown only if pinned items exist.
- "Recent" vertical list of item tiles (see §5 item tile spec), each showing type icon, title, snippet/metadata, tags as small chips.
- Bottom navigation: Home / Folders / Graph / Settings (4 tabs), `color/primary` active state.
- FAB (capture button) bottom-right, floating above bottom nav, opens Capture Type Picker.
- Empty state (no items yet): centered sparkle + box illustration, "Your vault is empty — start capturing" with primary button "Add your first item."

### 6.6 Search Results
- App bar with active search input (text cursor visible), back arrow left.
- Filter chip row below app bar: All / Notes / Files / Links / Voice, plus a "Filters" chip opening folder/tag/date filter sheet.
- Results list reuses item tile component; highlight matched search term in `color/accent-gold-dark` within title/snippet.
- Empty state: "No results for '[query]'" with a sparkle icon, suggestion to adjust filters.

### 6.7 Folder List / Folder Detail
- **Folder List:** App bar "Folders," list of folder rows (folder icon in `color/primary`, name, item count in `type/caption`), "+ New Folder" row/button at top or as FAB.
- **Folder Detail:** App bar shows folder name + back arrow + overflow menu (rename/delete/move). Body reuses item tile list filtered to that folder. FAB still available to add directly into this folder.

### 6.8 Tag List / Tag Detail
- **Tag List:** Tags displayed as a wrapped grid of pill chips (gold-tinted), tap to open Tag Detail. "Manage tags" overflow option for rename/merge/delete.
- **Tag Detail:** App bar shows `#tagname`, body reuses item tile list filtered to that tag.

### 6.9 Capture Type Picker
- Triggered from FAB — appears as a bottom sheet (white, `16dp` top radius) rising over a dimmed background.
- Four large tappable rows/cards, one per type: Note (pencil/doc icon), File (paperclip/folder icon), Link (chain icon), Voice (mic icon) — each icon in its respective `color/type-*` accent.
- Sheet has a small drag handle at top, title "Add to vault."

### 6.10 Note Editor
- App bar: back arrow, title field inline (placeholder "Untitled note"), checkmark/save icon right.
- Body: large text area, markdown-aware. Typing `[[` triggers an inline autocomplete dropdown listing matching existing item titles (white card, subtle shadow, `color/primary` highlight on hover/selection).
- Bottom toolbar (optional, minimal): formatting shortcuts (bold/italic/list), tag-add icon, folder-assign icon.
- Selected tags shown as small chips just below the title field.

### 6.11 File Item Add Flow
- Step 1 — System file picker invoked (native Android UI, not custom-designed).
- Step 2 — Preview screen: file thumbnail/icon large and centered, file name editable, file type + size shown in `type/caption`.
- Tag input and folder selector below preview (same components as Note Editor).
- Primary button: "Save to vault."

### 6.12 Link Item Add Flow
- Step 1 — Paste/share-intent brings up this screen directly with URL pre-filled.
- Preview card: fetched title + favicon + URL (if online) shown in a white card with subtle border; if offline, shows raw URL with a small "preview unavailable offline" caption in `color/text-secondary`.
- Optional annotation text field below: "Add a note about this link."
- Tag/folder selectors, primary button "Save to vault."

### 6.13 Voice Recorder
- Centered, focused layout — minimal distraction during recording.
- Large circular record button (`color/primary` fill, white mic icon), pulses/animates while recording.
- Live waveform visualization above the button in `color/accent-gold`.
- Timer display (`type/h1`) above waveform.
- After stopping: state transitions to "Transcribing..." with a small spinner/progress indicator and the sparkle motif (ties to icon branding — "processing" feels like the icon's glow).
- Final state: playback controls (play/pause/scrub) + editable transcript text area below, with a small caption noting transcript may need light edits, plus tag/folder selectors and "Save to vault" button.

### 6.14 Item Detail (adaptive shell)
- App bar: back arrow, item title, overflow menu (edit/delete/pin/move).
- Body adapts by type:
  - **Note:** rendered markdown body, wiki-links shown as tappable `color/primary` underlined text.
  - **File:** large preview (image/PDF thumbnail or icon), "Open" button, file metadata.
  - **Link:** preview card (title/favicon/URL) + annotation text below.
  - **Voice:** playback bar + full transcript text.
- Tags row below header, folder breadcrumb if assigned.
- **Backlinks panel** at bottom of every item detail screen: header "Linked from (N)," list of other item tiles that reference this one via wiki-link, tappable to navigate.

### 6.15 Graph View
- Full-screen canvas, `color/background` base.
- Nodes rendered as circles colored by `color/type-*`, sized slightly by connection count, with item title label appearing on zoom-in or tap.
- Edges as thin lines in `color/border`, highlighted gold when a connected node is selected.
- Top overlay: small floating search/filter bar ("Filter by type/tag") and a "center on my vault" reset-zoom button.
- Tapping a node opens a small preview card (bottom sheet, item tile style) with a "View" button leading to Item Detail.
- Pinch-to-zoom and pan are core interactions; include a subtle zoom-level indicator if helpful.

### 6.16 Settings (Home)
- App bar "Settings."
- Grouped list: App Lock, Backup & Export, Storage, About — each row with icon (in `color/primary`), label, chevron right.

### 6.17 Settings → App Lock
- Toggle: "Require biometric/PIN" (on by default, cannot be fully disabled given vault's privacy positioning — consider whether to allow disabling at all; if allowed, show a warning state in `color/warning`).
- "Change PIN" row.
- "Auto-lock after" row with a value picker (Immediately / 1 min / 5 min / 30 min).

### 6.18 Settings → Backup & Export
- Explanation text: "Archivo stores everything only on this device. Export an encrypted backup to keep a copy safe."
- "Export vault" primary button, triggers system share/save flow once generated.
- Last export date shown if applicable, in `type/caption`.
- Clear, non-alarming warning copy (in `color/warning` accent, not red/error) that uninstalling without exporting will permanently lose vault data.

### 6.19 Settings → Storage
- Simple breakdown: total vault size, broken into Notes / Files / Voice (with mini horizontal bar chart using `color/type-*` colors per segment).
- "Clear cache" or similar maintenance action if applicable.

### 6.20 Settings → About
- App icon centered, "Archivo" wordmark, version number, tagline "Your Knowledge. Always With You."
- Links: Privacy approach (explain local-only/no-account model briefly), licenses, contact/feedback.

---

## 7. Cross-Screen Patterns

- **Navigation:** Bottom nav (Home / Folders / Graph / Settings) persists across top-level screens; Search, Item Detail, and all "Add" flows are pushed on top (back arrow, no bottom nav visible).
- **Empty states:** Always pair the sparkle/box motif with a short, encouraging line and a direct action button — never a dead end.
- **Type-color consistency:** Once a content-type accent color is assigned (§2.3), use it consistently across item tiles, graph nodes, capture picker icons, and storage breakdown — this is the primary way users learn to visually parse content type at a glance.
- **No red unless destructive:** Reserve `color/error` strictly for destructive confirmations (delete item, delete folder) and validation errors — not for general warnings (use `color/warning` gold-amber instead), keeping the overall palette warm and non-alarming, consistent with brand tone.
