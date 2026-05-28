# Firebase via Environment Variables (Build-Time)

## Important
For Flutter Android/iOS, Firebase native SDK requires:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

These are consumed at build time, not from runtime Dart `assets/env/*.env`.

## Recommended setup
1. Store Firebase files in your secret manager as base64 values:
   - `FIREBASE_ANDROID_JSON_B64`
   - `FIREBASE_IOS_PLIST_B64`
2. Before `flutter run` or `flutter build`, generate files:
```bash
./scripts/generate_firebase_configs.sh
```

## Example local usage
```bash
export FIREBASE_ANDROID_JSON_B64="$(base64 < /path/to/google-services.json | tr -d '\n')"
export FIREBASE_IOS_PLIST_B64="$(base64 < /path/to/GoogleService-Info.plist | tr -d '\n')"
./scripts/generate_firebase_configs.sh
flutter run --dart-define=ENV=dev
```

## CI usage
Set the same two variables in CI secrets and run:
```bash
./scripts/generate_firebase_configs.sh
flutter test
flutter build apk --release
```

