# GitHub Actions workflows — FIXED V5 (final release)

**Builds:**
- 32663671985/32663589101 SUCCESS with compileSdk 34 + hardcoded release signing (31MB APK)
- Latest V3/V4 builds had `|| true` causing success even when build failed, only log uploaded

**Use FINAL workflows (no log hack, proper failure, uses committed keystore):**

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
      - name: Build APK Release
        run: flutter build apk --release --no-tree-shake-icons --verbose
      - name: Upload APK
        if: success()
        uses: actions/upload-artifact@v4
        with: {name: WAEC-CBT-Release-APK, path: build/app/outputs/flutter-apk/app-release.apk}
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
      - name: Build AAB Release
        run: flutter build appbundle --release --no-tree-shake-icons --verbose
      - name: Upload AAB
        if: success()
        uses: actions/upload-artifact@v4
        with: {name: WAEC-CBT-Release-AAB, path: build/app/outputs/bundle/release/app-release.aab}
```

**Keystore committed:** `android/app/waeccbt-upload.keystore` 2674 bytes alias `waeccbt` password `WaecCbt2026!` SHA `990a9cab...` — build.gradle hardcoded to use it, so release-signed (Play Store accepts).

**Secrets optional** (committed fallback), but keep:
- `ANDROID_KEY_PASSWORD=WaecCbt2026!`
- `ANDROID_KEYSTORE_BASE64` single-line 3568 chars (from keystore_secrets.txt) — copy ONLY base64 line.

After updating YML on GitHub web, push to main triggers APK (31MB) with real WAEC PREP icon.
