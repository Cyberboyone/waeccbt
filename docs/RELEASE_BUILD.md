# Releasing / Building the APK & AAB

The app is signed with a dedicated upload key so it can be published to Google Play.

> **Important:** the keystore file and its password must stay private. They are
> **not** committed to the repository — they live in a local `android/app/jambcbt-upload.keystore`
> file and are supplied to GitHub Actions as encrypted secrets.

## Signing key

| Item | Value |
|------|-------|
| Keystore file | `android/app/jambcbt-upload.keystore` (PKCS12) |
| Key alias | `jambcbt` |
| Store password | *(same as key password)* |
| Key password | *(see `keystore_secrets.txt` / your notes)* |

The keystore, key alias and passwords are also recorded locally in
`android/key.properties` and `keystore_secrets.txt` (both gitignored) so a local
`flutter build` release works out of the box.

> ⚠️ **Keep a backup.** If this keystore/password is lost, you cannot update the
> app on Google Play and would have to publish a new app.

## Option A — GitHub Actions (recommended)

The repo has two workflows:

- `.github/workflows/build-apk.yml` — builds a signed release APK on every push
  to `main`/`master` (and manually).
- `.github/workflows/build-aab.yml` — builds the signed Play Store `.aab` on manual
  trigger (`workflow_dispatch`).

### One-time setup: add secrets

In the GitHub repo → **Settings → Secrets and variables → Actions**, add:

1. `ANDROID_KEYSTORE_BASE64` — the base64 of the keystore (see `keystore_secrets.txt`).
2. `ANDROID_KEY_PASSWORD` — the keystore/key password.

Then:

- **APK:** push/merge to `main` → the APK workflow runs automatically.
- **AAB:** go to **Actions → Build Android App Bundle → Run workflow**.

Download the artifacts from the workflow run's **Artifacts** section
(`JAMB-CBT-App-Release` / `JAMB-CBT-App-Release-AAB`).

Upload the `.aab` to **Google Play Console** (Play App Signing will re-sign it with
your app signing key).

## Option B — Build locally

Requirements: Flutter SDK (stable), JDK 17, Android SDK (API 36).

```bash
flutter pub get
flutter pub run flutter_launcher_icons      # regenerate launcher icons
flutter build appbundle --release            # Play Store AAB
flutter build apk --release                  # installable APK
```

Outputs:
- AAB → `build/app/outputs/bundle/release/app-release.aab`
- APK → `build/app/outputs/flutter-apk/app-release.apk`

## Regenerating the keystore (only if you lose it)

```bash
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem \
  -days 10000 -nodes -subj "/CN=JAMB CBT, O=Nakudin, C=NG"
openssl pkcs12 -export -out android/app/jambcbt-upload.keystore \
  -inkey key.pem -in cert.pem -name jambcbt -passout pass:NEWPASSWORD
rm key.pem cert.pem
```
