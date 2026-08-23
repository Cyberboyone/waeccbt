# QUICK START — get the build running

You (the repo owner) must do these 2 steps on GitHub — the coding agent's token
cannot create workflow files or secrets (permission denied).

The two workflow files' full YAML is in docs/GITHUB_ACTIONS.md.
The keystore base64 + password are in `keystore_secrets.txt`
(gitignored, never committed — ask the agent session for it if you lost it).

> ⚠️ Use ONLY the values from the current `keystore_secrets.txt`.
> Passwords printed in older versions of this doc belonged to a different,
> unrecoverable keystore and will make signing fail.

====================================================================
STEP 1 — Add the TWO workflow files to the repo (on GitHub website)
====================================================================

1. Open https://github.com/Cyberboyone/jambcbt  (make sure you're on the `main` branch)
2. Click "Add file" → "Create new file"
3. In the filename box type:  .github/workflows/build-apk.yml
4. Paste the content of the FIRST yaml block from docs/GITHUB_ACTIONS.md
5. Click "Commit new file"
6. Repeat steps 2–5 for:  .github/workflows/build-aab.yml  (SECOND yaml block)

   → That's TWO files total. Both are needed (APK + Play Store AAB).
   → Adding build-apk.yml to main triggers the first APK build right away —
     do STEP 2 first if you want that first build to be signed successfully.

====================================================================
STEP 2 — Add the TWO secrets
====================================================================

1. Go to repo → Settings → "Secrets and variables" → "Actions"
2. Click "New repository secret"
   - Name:  ANDROID_KEYSTORE_BASE64
   - Secret:  the ENTIRE single-line base64 string from keystore_secrets.txt
              (in the "GITHUB SECRET 2" section, after the dashed line)
   - Click "Add secret"
3. Click "New repository secret" again
   - Name:  ANDROID_KEY_PASSWORD
   - Secret:  the password line from keystore_secrets.txt
              (in the "GITHUB SECRET 1" section)
   - Click "Add secret"

====================================================================
STEP 3 — Run the builds
====================================================================

- APK:  push/merge anything to `main` → "Build Android APK" runs automatically.
        (Or: Actions → "Build Android APK" → "Run workflow")
- AAB (Play Store):  Actions → "Build Android App Bundle (Play Store)" → "Run workflow"

Download your files from the workflow run's "Artifacts" section
(`JAMB-CBT-App-Release` / `JAMB-CBT-App-Release-AAB`).

Upload the `.aab` to Google Play Console (Play App Signing re-signs it with
your app signing key). Keep `keystore_secrets.txt` and the
`android/app/jambcbt-upload.keystore` file backed up — losing them means you
can never update the app on Play.
====================================================================
