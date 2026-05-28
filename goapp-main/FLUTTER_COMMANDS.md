# Flutter Commands (Dev / Test / Prod)

This file lists the most common Flutter commands used in this project.

---

## Development
### Run app (debug)
```bash
flutter run
```

### Run on a specific device
```bash
flutter devices
flutter run -d <device_id>
```

### Run with flavor/env (if needed)
```bash
flutter run --dart-define=ENV=dev
```

### Run with Maps key
```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key
```

---

## Testing
### Run all tests
```bash
flutter test
```

### Run a single test file
```bash
flutter test test/<file>_test.dart
```

### Run tests with expanded output
```bash
flutter test --reporter expanded
```

---

## Build (Android)
### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### Build APK for ARM64 only
```bash
flutter build apk --release --target-platform android-arm64
```

### Analyze APK size
```bash
flutter build apk --analyze-size --target-platform android-arm64
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### Android Signing (Release)
1. Create a keystore (one‑time):
```bash
keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias goapp
```

2. Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=goapp
storeFile=key.jks
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
  signingConfigs {
    release {
      keyAlias keystoreProperties['keyAlias']
      keyPassword keystoreProperties['keyPassword']
      storeFile file(keystoreProperties['storeFile'])
      storePassword keystoreProperties['storePassword']
    }
  }
  buildTypes {
    release {
      signingConfig signingConfigs.release
    }
  }
}
```

---

## Build (iOS)
### Debug (simulator)
```bash
flutter build ios --debug --simulator
```

### Release (device)
```bash
flutter build ios --release
```

### iOS Archive (Xcode)
```bash
flutter build ios --release
open ios/Runner.xcworkspace
```
Then in Xcode:
1. Select `Runner` → `Any iOS Device`
2. Product → Archive
3. Distribute App

---

## Production Checklist (Suggested)
```bash
flutter clean
flutter pub get
flutter test
flutter build apk --release
```

---

## Useful Tools
### Format code
```bash
dart format .
```

### Analyze code
```bash
flutter analyze
```

---

## CI (Recommended)
### GitHub Actions (example)
```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## Play Store Internal Testing
1. Build an App Bundle:
```bash
flutter build appbundle --release
```

2. Go to **Google Play Console → Testing → Internal testing**
3. Create a release and upload:
```
build/app/outputs/bundle/release/app-release.aab
```
4. Add testers (email list or Google Group)
5. Review and roll out to Internal

---

## iOS TestFlight Upload
1. Build release:
```bash
flutter build ios --release
```

2. Open Xcode:
```bash
open ios/Runner.xcworkspace
```

3. In Xcode:
   - Select **Runner** → **Any iOS Device**
   - **Product → Archive**
   - **Distribute App → App Store Connect → Upload**

4. In **App Store Connect**:
   - Go to TestFlight
   - Add build to internal testers
