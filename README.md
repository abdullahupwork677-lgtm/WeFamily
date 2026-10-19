# WeFamily

Bilingual (English + Arabic) family safety app with interactive family tree, live location sharing, and family chat.

## Features (MVP — Mock Mode)

- Splash + 3-screen onboarding with language switcher (EN | ع)
- Phone login (mock OTP — any 6 digits works) with country picker (+966, +971, +92, etc.)
- Profile setup (name, birth date, gender)
- Create/join family circle + share invite link
- Home: OpenStreetMap + draggable bottom sheet + member cards (battery, place, last updated)
- Family tree: pan/zoom, gold connectors, search, list toggle, add relative
- Person profile (About / Relatives / Photos / Stories)
- Family chat: text + location messages + quick chips
- Safety tab: hold-to-activate SOS UI + emergency contacts (demo only)
- Settings: language switch, location sharing toggle, ghost mode, logout
- Notifications list (static mock)

## Run

```bash
cd wefamily
flutter pub get
flutter run
```

Requires Flutter 3.47+ (uses `withValues`, generated l10n import path).

## Mock vs Firebase

Mock mode is ON by default (`lib/core/constants/config.dart` → `useMockData = true`).

### To enable Firebase (Phase 6)

1. Create a Firebase project at https://console.firebase.google.com
2. Enable **Phone Auth**, **Firestore**, **Storage**, **Cloud Messaging**
3. Add Android app (package: `com.wefamily.wefamily`) and download `google-services.json` → place in `android/app/`
4. Add iOS app and download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Run:

```bash
flutterfire configure
```

6. Set `useMockData = false` in `lib/core/constants/config.dart`

Without config files the app runs fully in mock mode — no crashes.

## Project Structure

```
lib/
  main.dart
  app/           # app.dart, router.dart
  core/          # theme, widgets, utils, constants
  l10n/          # ARB files + generated localizations
  features/      # onboarding, auth, circle, home, member, tree, chat, safety, settings, notifications, shell
  data/          # models, mock repositories
```

## Design System

- Primary: `#5B21B6` · Gradient to magenta `#C026D3` · Gold accent `#C9A24D`
- Background: `#F7F4FB` · Surface: white cards, 24px radius
- Fonts: Plus Jakarta Sans (EN) / IBM Plex Sans Arabic (AR)
- Pill buttons & tabs · RTL fully supported via `Directionality`

## Privacy

- Location sharing explained before permission request
- Ghost mode pause toggle in Settings
- Visible "sharing active" indicator on Home
- No "tracking" wording — always "safety" / "share location" / "check in"

## Known Gaps / TODOs

- Firebase not wired (needs owner's config files) — mock mode complete
- 3D icons from design are placeholders — use Material Symbols for now
- Photo upload not implemented (optional)
- Push notifications not implemented
- Real phone calling uses TODO (url_launcher pending)
- Pets/Keys tabs show "Coming soon" (out of MVP scope)
