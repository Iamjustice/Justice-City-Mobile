# Justice City Mobile (Flutter)

Production mobile client for Justice City, integrated with:
- Supabase Auth/Storage
- Justice City Node API (`/api/*`)

## Feature Coverage
- Auth and profile updates
- Verification flow (email OTP, phone OTP, KYC document upload, Smile ID submit)
- Role-aware routing and dashboards (admin/operator/buyer)
- Listings and property details (operator scope)
- Chat conversations, messages, and attachments
- Transaction, escrow, and dispute flows
- Services, provider package lookup, callback/tour requests, hiring application

## Prerequisites
- Flutter stable
- Dart 3.x
- Android Studio and/or Xcode

## Run Locally
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

flutter run \
  --dart-define=SUPABASE_URL="https://YOUR.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY" \
  --dart-define=API_BASE_URL="https://YOUR_NODE_API_BASE"
```

## Quality Gates
```bash
flutter analyze --no-fatal-warnings --no-fatal-infos
flutter test
```

## CI (Codemagic)
`codemagic.yaml` includes workflows for:
- Flutter web build
- Android release builds (AAB/APK)
- iOS IPA build

Each workflow runs:
1. `flutter pub get`
2. `build_runner` code generation
3. `flutter analyze`
4. `flutter test`
5. platform build

## Notes
- Listing management screens map to operator APIs (`/api/agent/listings`), so listing status updates are role-restricted in UI and backend.
- Verification trust gate is fail-closed on unresolved status for protected routes.
