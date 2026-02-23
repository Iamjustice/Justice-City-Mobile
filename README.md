# Justice City (Flutter Starter)

This is a **starter Flutter mobile app** scaffolded to match the Justice-City backend setup:
- Supabase Auth + Storage
- Custom Node API (Express) endpoints under `/api/*`

## 1) Prerequisites
- Flutter (stable)
- Dart 3.x
- Android Studio / Xcode as needed

## 2) Configure environment
Create a file at `lib/env.dart` OR pass via `--dart-define` (recommended).

### Recommended: --dart-define
Run:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://YOUR.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY" \
  --dart-define=API_BASE_URL="https://justicecityltd.com"
```

`API_BASE_URL` should point at your Node server (same domain as your deployed web app is fine).

## 3) What’s included
- go_router routing: /auth, /home, /listings, /chat, /dashboard
- Riverpod state management
- Supabase session listener + basic gate logic (signed-in required)
- Typed API client (Dio) with JWT injection from Supabase session
- Minimal repositories: AuthRepository, ListingsRepository, ChatRepository (skeleton methods)

## 4) Next steps
- Replace placeholder screens with real UI
- Implement the remaining endpoints (see `lib/data/api/endpoints.dart`)
- Add role-based gating (agent/admin) by reading your profile/verification tables
