# JAMB CBT

A complete **computer-based test (CBT) practice app** for the Nigerian **UTME (JAMB)** —
rebranded from the GST CBT app codebase and filled with **2,000 original, syllabus-aligned
questions** across 10 core subjects.

## Subjects (200 questions each)

| Code | Subject | Category |
|------|---------|----------|
| ENG | Use of English (compulsory) | Compulsory |
| MAT | Mathematics | Science |
| PHY | Physics | Science |
| CHE | Chemistry | Science |
| BIO | Biology | Science |
| ECO | Economics | Commercial |
| GOV | Government | Arts |
| LIT | Literature in English | Arts |
| COM | Commerce | Commercial |
| ACC | Principles of Accounts | Commercial |

**Practice mode** draws 50 questions per session. **Timed exam mode** is aligned to the
real UTME format: Use of English = 60 questions / 40 minutes, all other subjects = 40
questions / 30 minutes. In both modes, questions and answer options are shuffled on every
attempt so you never see the same order twice.

## How questions are organised

Question banks are bundled as JSON in `assets/questions/<subject>.json`:

```json
{
  "course_id": "phy",
  "course_name": "Physics",
  "version": "1.0.0",
  "questions": [
    {
      "id": "phy_001",
      "text": "The SI unit of force is the:",
      "options": ["Joule", "Watt", "Newton", "Pascal"],
      "correct_index": 2,
      "explanation": "Force is measured in newtons (N).",
      "difficulty": 1
    }
  ]
}
```

The app seeds these into local (Hive) storage on first launch, so everything works
**100% offline**. Questions are drawn from the official JAMB syllabus — see
[`docs/JAMB_SYLLABUS.md`](docs/JAMB_SYLLABUS.md) for the topic outline per subject.

## Rebranding notes

- App name: **JAMB CBT** (package `gst_cbt` → `jamb_cbt`)
- Brand colour: JAMB green `#00A859` (replaces the old cyan)
- All user-facing copy, PDF report headers, share messages and the launcher icon updated
- Android application ID / iOS bundle ID: **`com.nakudin.jambcbt`**
- Firebase (Analytics) removed; AdMob-only ads (IDs set via `AppConstants` and the
  Android manifest)

## Regenerating / editing questions

Question source lives in `tools/gen_<subject>.py`. To regenerate all JSON files:

```bash
cd tools
for f in gen_*.py; do python3 "$f"; done
python3 validate.py   # checks 200 questions/subject, 4 options, valid indices
```

To add/edit questions, edit the relevant `tools/gen_*.py` and re-run it.

## Building the app

```bash
flutter pub get
flutter pub run flutter_launcher_icons   # regenerate native icons from assets/icon.png
flutter run
```

### Release builds (Play Store)

The app is signed with a dedicated upload key. See
[`docs/RELEASE_BUILD.md`](docs/RELEASE_BUILD.md) for the full signing + CI build
guide. Two GitHub Actions workflows build a signed **APK** and **Play Store AAB**;
they need the `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEY_PASSWORD` repo secrets.

> AdMob is wired up (banner/interstitial/rewarded) with placeholder ad unit IDs in
> `lib/config/constants.dart` and the Android manifest — replace them with your own
> AdMob IDs before publishing.
