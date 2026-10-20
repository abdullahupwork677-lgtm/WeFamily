# WeFamily — Realtime Roadmap (Firebase + Chat + Location)

Last updated: 2026-10-20

## Goal

Replace the mock layer with real backend features, in this order:

1. **Firebase foundation** — project, config files, packages wired into Android build
2. **Real Login / Signup** — Firebase Auth (email + password). OTP stays mock/skip for now.
3. **Map UI redesign** — premium 2026 look (provider TBD below)
4. **GPS + live location sharing** — device GPS -> Firestore -> family map in realtime
5. **Realtime chat** — Firestore messages between circle members

Everything is documented here after each stage.

---

## Stage 1 — Firebase foundation (DONE)

### What the owner must do (one-time, ~10 min)

1. Go to https://console.firebase.google.com -> **Add project**
   - Name: `wefamily`
   - Google Analytics: optional (can skip)
2. In the project -> **Add app** -> Android
   - Android package name: `com.wefamily.wefamily` (must match exactly)
   - App nickname: `WeFamily Android`
   - SHA-1: needed later for Google Sign-In only; skip for now
3. Download **google-services.json**
4. Put it here: `android/app/google-services.json`
5. In Firebase Console -> **Build > Authentication > Get started**
   - Enable **Email/Password** provider
6. In Firebase Console -> **Build > Firestore Database** -> Create database
   - Location: choose closest (e.g. `me-central1` for Middle East)
   - Start in **production mode** (rules will be added by us)
7. Tell the assistant: "firebase ready" (so we wire everything)

### What the assistant will do after that

- Re-add packages: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- Wire `google-services.json` via `com.google.gms.google-services` Gradle plugin
- Configure Firestore security rules
- Rebuild APK (memory-safe build settings already in place)

### Why not phone OTP yet?

Firebase Phone Auth normally requires the Blaze (pay-as-you-go) plan plus reCAPTCHA setup.
Owner asked to skip OTP for now — it stays as a mock screen with a Skip button.

---

## Stage 2 — Real Login / Signup (IN PROGRESS)

**Decision: Firebase Auth email + password** (owner confirmed 2026-10-20).
**Owner action needed:** Firebase Console -> Authentication -> Sign-in method -> enable
**Email/Password** (otherwise login fails with "operation-not-allowed").
Google Sign-In added later (needs SHA-1 in console).

- Email + password signup / login screens (replace current phone mock screens)
- Firebase Auth state drives routing: logged out -> login, logged in -> circle/home
- Profile setup (name, gender, birth date) saved to Firestore `users/{uid}`
- Session provider switches from SharedPreferences flags to Firebase auth stream
- Keep "Skip (demo)" for quick screen testing while building

---

## Stage 3 — Map UI redesign (planned)

Current: plain OSM raster tiles + basic markers.

**Decision: Mapbox** (owner confirmed 2026-10-20). Approach: `flutter_map` + Mapbox raster styles
(`streets-v12`, `dark-v11`, `satellite-v9`) — zero heavy native deps, fast builds.
Optional later upgrade: official `mapbox_maps_flutter` for vector/3D.

### What the owner must do for Mapbox

1. Create free account: https://account.mapbox.com/auth/signup/
2. Go to https://account.mapbox.com/access-tokens/
3. Copy the **Default public token** (starts with `pk.`)
4. Give it to the assistant — it goes into the app config (safe to embed, it's a public token)

Redesign goals:
- Full-bleed map, glassmorphism member chips at bottom sheet
- Animated avatars with live status ring (online/offline/moving)
- Custom gradient marker pins per family member (initial letters)
- Speed/accuracy badges, "last seen" relative time
- Route/trail polyline for a member's recent path
- Dark mode map style matching brand

---

## Stage 4 — GPS + live location sharing (planned)

### How GPS works (plain explanation)

1. The phone's GPS chip + network location gives **latitude/longitude** coordinates.
2. The app asks Android for permission (`ACCESS_FINE_LOCATION`); background sharing also needs
   `ACCESS_BACKGROUND_LOCATION` (+ Android 14 foreground service type `location`).
3. The `geolocator` package streams position updates (accuracy, speed, heading, timestamp).
4. We write each member's latest position to Firestore:
   `circles/{circleId}/members/{uid}` -> `{lat, lng, accuracy, speed, battery, updatedAt}`
5. Every family member's app **listens** to those documents (`snapshots()`) and moves the map
   markers in realtime. No polling needed.
6. Battery saving: update only when moved > 25m OR every 60s; pause when stationary.

### What we need from the owner

- Nothing for GPS itself (hardware + free).
- For background ("app closed") sharing: Android will show a persistent notification — user must
  see and accept this design.
- Map provider key (Stage 3 decision).

---

## Stage 5 — Realtime chat (planned)

- Firestore collection: `circles/{circleId}/messages/{messageId}`
  - `{senderId, text, type: text|location, lat, lng, createdAt}`
- Stream messages ordered by `createdAt` -> instant chat UI updates
- Location messages draw a tappable preview card -> opens map
- Typing indicator + read receipts (optional, later)

---

## Firestore data model (draft)

```
users/{uid}                    -> {name, email, gender, birthDate, photoUrl, createdAt}
circles/{circleId}             -> {name, ownerUid, inviteCode, memberUids[], createdAt}
circles/{circleId}/members/{uid} -> {lat, lng, accuracy, speed, battery, isSharing, updatedAt}
circles/{circleId}/messages/{id} -> {senderId, text, type, lat, lng, createdAt}
```

## Build notes (this PC)

- 7.8 GB RAM total; Gradle heap capped at 2560m, workers=1, Kotlin incremental off
- Build only `--target-platform android-arm64` (phones)
- Builds run detached (PowerShell shell kills child processes otherwise)
- Firebase packages make builds heavier — keep the above settings

## Progress log

- 2026-10-20: Roadmap created. Waiting on Firebase project + google-services.json from owner.
- 2026-10-20: Decisions locked — Mapbox for maps, Firebase email/password auth. Mapbox public token received and configured in `lib/core/constants/config.dart`.
- 2026-10-20: **Map UI v1 shipped** (flutter_map + Mapbox raster):
  - Dark (default), streets and satellite styles; layers button cycles them
  - Pulsing avatar markers with gold selection ring + name chip
  - Glass member chips / top bar, glass mini card with Route + Details actions
  - Synth route trail polyline (glow + core line) around selected member
  - Recenter button, dark map backdrop, avatar strip for quick focus
  - OSM fallback if token is ever blanked
  - Files: `lib/features/home/home_screen.dart`, `lib/core/constants/config.dart`
- 2026-10-20: **GPS live tracking v1 shipped (local device)**:
  - `lib/core/services/location_service.dart`: permission flow (request + denied handling),
    high-accuracy stream (`distanceFilter: 15m`), one-shot current fix
  - `livePositionProvider` (Riverpod StreamProvider) — emits null when permission denied / GPS off
  - Home map: current user's marker now uses the real device position, accuracy circle drawn in
    meters, map auto-centers on the first fix, recenter button uses live position
  - "Location off — tap to retry" glass chip when permission/GPS unavailable
  - Family-wide sharing still needs Firestore (waiting on `android/app/google-services.json`)
- 2026-10-20: Still waiting on `android/app/google-services.json` for Firebase (login/signup next).

- 2026-10-20: **Task 1 shipped (map speed)**. Cause of the slowdown: Mapbox raster tiles had no disk
  cache (full re-download on every launch/style switch), every GPS fix rebuilt the whole map screen,
  every marker ran an infinite pulse animation, and trail points were recomputed in `build()`.
  Fixes: disk tile cache (`lib/core/services/tile_cache.dart`, 250 MB, LRU-ish trim), cached last
  position as initial center, position stream throttled to 1/s, `RepaintBoundary` per marker,
  pulse only on the current user, shimmer skeleton until the first tiles settle.
- 2026-10-20: **Task 2 shipped (Soft UI restyle)**: borderless white cards with black 8% soft shadow
  (blur 24, y8), softer inputs, pill buttons (primary gradient + secondary grey) with tap-scale,
  borderless pill tabs with soft shadows, rounded white bottom nav (purple active), 32px bottom
  sheets, `SoftIllustration` placeholder (TODO asset).
- 2026-10-20: **Task 3 shipped (home map rebuild, reference-matched)**: CARTO Positron light tiles
  (configurable in `config.dart`), avatar markers with white ring + pin tail/dot anchored at the
  coordinate, heading cone for moving members, "Here for / Driving km/h" bubbles with place icon,
  low-battery badge, self pulse halo + accuracy circle, animated marker movement (800 ms),
  Google-style overlays (settings, circle pill, invites/chat, add place, recenter, layers sheet with
  fit-all), Check in / SOS pills, 3-snap draggable sheet with premium banner, icon tabs, member
  cards, invite tip card and add-person card. Home shortcuts switch the shell tab via
  `shellTabProvider`.
- 2026-10-20: **Task 4 shipped (real location sharing)**. Real Firebase mode is now the default
  (`useMockData = false`; tests run with `--dart-define=USE_MOCK_DATA=true`). Added:
  `TrackingController` with one GPS stream (`distanceFilter` 15 m, high accuracy) wrapped in an
  Android foreground service and iOS background mode, write policy (15 m / 10 s cap, 30 s while
  moving, 2 min stationary heartbeat), automatic `sinceAt` reset after 150 m, reverse geocoding
  every ~200 m (`placeLabel`), battery level via `battery_plus`, ghost mode / pause that writes
  immediately, and a friendly permission sheet (while-in-use, all-the-time, permanently denied with
  Open settings, battery optimisation guide). `CircleRepository` creates circles + unique invite
  codes transactionally, syncs members live from `circles/{id}/members`, and stores `lastLocation`
  as a nested map with server timestamps. Profile names are stored in `users/{uid}`. Home and
  Settings now read/write real data; splash/login sync profile + membership. Added
  `firestore.rules` (publish it in the console) and the Android/iOS permission entries.
  Build note: re-adding `cloud_firestore` overflowed D8 at 3072m; `-Xmx4096m` with
  `org.gradle.parallel=false` fixed `mergeExtDexRelease` (APK 27.7 MB).
- 2026-10-20: **Task 5 shipped (create / join / manage)**. Circle screen now has a real 6-box
  invite-code input (auto uppercase, paste supported) with localised errors (invalid / already
  member / full / offline), and join runs in a Firestore transaction (code lookup -> duplicate +
  member-cap checks -> add uid + member doc). New `circle_management_screen.dart`: invite code with
  copy, native share and WhatsApp, owner code regeneration, owner member removal, delete circle
  (owner) or leave circle (member) with confirmations; leaving/deleting stops tracking, clears the
  session and routes back to `/circle`. Manage entry points added to the home circle switcher and
  Settings. Home listens for membership loss (removed while app open) and redirects to the circle
  screen. `url_launcher` added. `firestore.rules` v2 adds join/leave/regenerate/remove/delete
  rules (signed-in `get` on circles for code lookup; list stays member-only; invite-code create
  owner-only, delete owner-only). Publish the new rules before two-phone testing.
  Known limitation: Task 5's link-member-to-tree item is deferred because the tree screen still
  uses mock data (no tree datastore yet), so the "green realtime dot" cannot be real.

- 2026-10-20: **Task 6 shipped (functional family chat)**. Chat now streams `circles/{id}/messages`
  in real time (newest at the bottom, 30-message pagination on scroll-up, date chips, sender
  avatars/names, localised quick chips, quick "I'm on my way / I've reached / Call me"). Text
  bubbles are purple for me / white for others (RTL mirrored), with sending / sent / failed+retry
  states (Firestore `hasPendingWrites` + local failed queue). Photos: camera/gallery sheet,
  flutter_image_compress (max 1600 px, q80), Cloudinary unsigned upload with per-bubble progress,
  full-screen zoom viewer. Voice notes: hold-to-record with slide-to-cancel + tap-to-lock,
  amplitude waveform, 2-minute cap, m4a upload to Cloudinary, playback with just_audio
  (single player, 1x/1.5x/2x speed). Location messages render a mini map + "Open on map".
  Offline persistence enabled; unread dot on the Chat tab (last-read timestamp per circle).
  Android RECORD_AUDIO + iOS microphone/camera/photo descriptions added; messages rules now
  restrict create to the sender and type whitelist, update/delete to the sender.
  **Manual step still needed: the Cloudinary preset `ml_default` is not whitelisted for unsigned
  uploads** (verified: "Upload preset must be whitelisted for unsigned uploads"). In the
  Cloudinary console, open Settings -> Upload -> Upload presets -> `ml_default` -> set Signing
  mode to Unsigned (or create an unsigned preset and update `AppConfig.cloudinaryPreset`).
  FCM push is not implemented (needs Blaze + a Cloud Function); unread badge covers in-app.
  Task 5 tree-link remains deferred until the tree has a real datastore.
