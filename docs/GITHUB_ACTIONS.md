# GitHub Actions workflows — FIXED V4 (log capture + pub get fix)

**Latest status:**
- 32663671985/32663589101 SUCCESS after compileSdk 34 + hardcoded release signing
- 32665599019/32667217909 fail at `flutter pub get` → fixed by `rm -f pubspec.lock`
- 32667261713/32667217909 fail at Build APK/AAB after pub get success → need verbose log

**Use these FIXED V4 workflows (with log upload):**

## APK `.github/workflows/build-apk.yml`
```yaml
name: Build Android APK
on:
  push:
    branches: [main, master]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-java@v5
        with: {distribution: 'zulu', java-version: '17'}
      - uses: subosito/flutter-action@v2
        with: {flutter-version: '3.22.2', channel: 'stable'}
      - name: Clean pubspec.lock
        run: rm -f pubspec.lock
      - run: flutter pub get
      - name: Build APK Release (verbose log)
        run: |
          flutter build apk --release --verbose 2>&1 | tee build.log || true
          ls -lh build/app/outputs/flutter-apk/ || true
          cat build.log | tail -200 || true
      - name: Upload APK
        if: always()
        uses: actions/upload-artifact@v4
        with: {name: WAEC-CBT-Release-APK, path: build/app/outputs/flutter-apk/app-release.apk, if-no-files-found: warn}
      - name: Upload Build Log
        if: always()
        uses: actions/upload-artifact@v4
        with: {name: build-log-apk, path: build.log, if-no-files-found: warn}
```

## AAB `.github/workflows/build-aab.yml`
```yaml
name: Build Android App Bundle (Play Store)
on:
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-java@v5
        with: {distribution: 'zulu', java-version: '17'}
      - uses: subosito/flutter-action@v2
        with: {flutter-version: '3.22.2', channel: 'stable'}
      - name: Clean pubspec.lock
        run: rm -f pubspec.lock
      - run: flutter pub get
      - name: Build AAB Release (verbose)
        run: |
          flutter build appbundle --release --verbose 2>&1 | tee build-aab.log || true
          ls -lh build/app/outputs/bundle/release/ || true
          cat build-aab.log | tail -200 || true
      - name: Upload AAB
        if: always()
        uses: actions/upload-artifact@v4
        with: {name: WAEC-CBT-Release-AAB, path: build/app/outputs/bundle/release/app-release.aab, if-no-files-found: warn}
      - name: Upload Build Log
        if: always()
        uses: actions/upload-artifact@v4
        with: {name: build-log-aab, path: build-aab.log, if-no-files-found: warn}
```

After updating, download `build-log-apk` artifact from Actions run to see actual Flutter error.
