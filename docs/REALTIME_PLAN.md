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
