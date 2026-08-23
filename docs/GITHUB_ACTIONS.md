# GitHub Actions workflows

> ⚠️ These workflow files could not be pushed from the automated coding agent
> (its GitHub App token has no `workflows` permission). Create the two files
> below in your repo via the GitHub web editor (or your own machine) to enable
> the CI builds. Once they exist, the builds run as described in
> [`RELEASE_BUILD.md`](RELEASE_BUILD.md).

## 1. `.github/workflows/build-apk.yml`

```yaml
name: Build Android APK

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    env:
      KEY_ALIAS: jambcbt
      KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
      KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
      KEYSTORE_PATH: ${{ github.workspace }}/android/app/jambcbt-upload.keystore

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v5

      - name: Setup Java
        uses: actions/setup-java@v5
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.7'
          channel: 'stable'

      - name: Install Dependencies
        run: flutter pub get

      - name: Generate App Icons
        run: flutter pub run flutter_launcher_icons

      - name: Decode Keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: echo "$KEYSTORE_BASE64" | base64 -d > android/app/jambcbt-upload.keystore

      - name: Build APK
        run: flutter build apk --release --no-tree-shake-icons --android-skip-build-dependency-validation

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: JAMB-CBT-App-Release
          path: build/app/outputs/flutter-apk/app-release.apk
```

## 2. `.github/workflows/build-aab.yml`

```yaml
name: Build Android App Bundle (Play Store)

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    env:
      KEY_ALIAS: jambcbt
      KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
      KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
      KEYSTORE_PATH: ${{ github.workspace }}/android/app/jambcbt-upload.keystore

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v5

      - name: Setup Java
        uses: actions/setup-java@v5
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.7'
          channel: 'stable'

      - name: Install Dependencies
        run: flutter pub get

      - name: Generate App Icons
        run: flutter pub run flutter_launcher_icons

      - name: Decode Keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: echo "$KEYSTORE_BASE64" | base64 -d > android/app/jambcbt-upload.keystore

      - name: Build App Bundle
        run: flutter build appbundle --release --no-tree-shake-icons --android-skip-build-dependency-validation

      - name: Upload AAB Artifact
        uses: actions/upload-artifact@v4
        with:
          name: JAMB-CBT-App-Release-AAB
          path: build/app/outputs/bundle/release/app-release.aab
```

## Required secrets

Add these in **Settings → Secrets and variables → Actions**:

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | base64 of the upload keystore (see `keystore_secrets.txt`) |
| `ANDROID_KEY_PASSWORD` | the keystore password (see `keystore_secrets.txt`) |
