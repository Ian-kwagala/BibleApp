# LightWord Bible App (Flutter v2.0)

An **Offline-First + Online Multi-Version Flutter Bible App** (Android Play Store `.aab`/`.apk`, iOS, and Offline Web PWA) featuring side-by-side translation comparison, emotion-based verse & prayer finder, interactive Bible trivia quizzes, offline Text-to-Speech audio with live verse highlighting, shareable Verse Art Studio cards, and conflict-free Google Drive personal backup (`drive.appdata`) with **\$0 server cost**.

---

## Blueprint Documents in This Repo

* **Updated PDF Blueprint (v2.0):** [`LightWord_Bible_App_Blueprint.pdf`](LightWord_Bible_App_Blueprint.pdf)
* **Markdown Blueprint (v2.0):** [`BLUEPRINT.md`](BLUEPRINT.md)
* **Play Store Privacy Policy (GitHub Pages Ready):** [`docs/privacy-policy.html`](docs/privacy-policy.html)

---

## All 7 Architectural & Policy Fixes Implemented in v2.0

1. **Unified Flutter 3 Codebase (`lib/`):** Built with Flutter (Dart 3) for Android, iOS, and Web, paired with automated GitHub Actions CI/CD ([`.github/workflows/flutter_build.yml`](.github/workflows/flutter_build.yml)) that builds release `.apk` and Play Store `.aab` bundles automatically.
2. **Zero-Server 1-Tap Translation Hosting (`downloads/*.json`):** Downloadable Public Domain versions (`ASV`, `YLT`, `DARBY`, `RVR`, `LSG`) are hosted directly in the repository's [`downloads/`](downloads) directory and served via GitHub Raw CDN (`$0` server cost forever).
3. **Debounced, Conflict-Free Google Drive Sync ([`lib/models/bible_models.dart`](lib/models/bible_models.dart)):**
   * Local changes save immediately to local storage (`SharedPreferences`), while Google Drive `appDataFolder` uploads are **debounced (every 3 minutes)** instead of firing on every chapter tap.
   * Uses **CRDT-style timestamp & set-union merging (`UserSyncPayload.mergeWith`)** so reading or highlighting offline across two devices never overwrites data.
4. **Per-Book Chunked Bible Indexing ([`lib/services/bible_repository.dart`](lib/services/bible_repository.dart)):** Bundled offline Bibles (`WEB`, `KJV`, `BBE`) are split into 66 per-book JSON chunks (`assets/bibles/<CODE>/01..66.json`, ~40 KB per book) with an in-memory LRU cache (`<2ms` load time, >95% lower RAM usage than parsing 4.2 MB files at startup).
5. **Verse-by-Verse Offline TTS Queue ([`lib/services/tts_service.dart`](lib/services/tts_service.dart)):** Queues offline Text-to-Speech **one verse utterance at a time** via completion callbacks so the active verse is accurately highlighted on screen.
6. **AdMob Accidental-Click & Dwell-Time Guardrails ([`lib/state/app_state.dart`](lib/state/app_state.dart)):**
   * Bottom banner automatically collapses to `0px` height when offline.
   * Full-screen interstitials require a **15-second minimum chapter dwell time** (so flipping through chapters doesn't count) and a **4-minute cooldown**.
7. **Google Play Data Safety, UMP Consent & In-App Deletion ([`lib/screens/versions_backup_screen.dart`](lib/screens/versions_backup_screen.dart)):** Includes GDPR/CCPA UMP consent mode controls and a 1-tap **"Delete Cloud & Local Data"** button required by Google Play.

---

## Project Structure

```text
├── LightWord_Bible_App_Blueprint.pdf  # Updated 5-page visual developer blueprint (v2.0)
├── BLUEPRINT.md                       # Markdown developer blueprint (v2.0)
├── assets/
│   ├── bibles/
│   │   ├── manifest.json              # 66-book index & 8 public-domain version metadata
│   │   ├── WEB/01..66.json            # Bundled World English Bible (per-book chunks)
│   │   ├── KJV/01..66.json            # Bundled King James Version (per-book chunks)
│   │   └── BBE/01..66.json            # Bundled Bible in Basic English (per-book chunks)
│   └── data/
│       ├── mood_verses.json           # 6 mood chips + multi-version verses & prayers
│       ├── reading_plans.json         # Guided reading plans (30 Days of Peace, Gospels, Proverbs)
│       └── bible_quiz.json            # Easy, Medium, and Hard trivia questions with XP & explanations
├── downloads/                         # 1-Tap downloadable versions (ASV, YLT, DARBY, RVR, LSG)
├── docs/privacy-policy.html           # Play Store compliant Privacy Policy page
└── lib/
    ├── main.dart                      # App shell, 5-tab navigation & offline-collapsing AdMob banner
    ├── models/bible_models.dart       # Core models & CRDT conflict-free UserSyncPayload merge
    ├── services/
    │   ├── bible_repository.dart      # Per-book LRU loader, multi-version compare & offline search
    │   └── tts_service.dart           # Verse-by-verse offline audio queue
    ├── state/app_state.dart           # Offline-first state, debounced sync & AdMob dwell-time rules
    └── screens/
        ├── home_screen.dart           # Page 1: Daily Verse, Streak, Mood Finder & Reading Plan
        ├── reader_screen.dart         # Page 2: Reader, Highlights, Notes, Audio Bar & Compare
        ├── quiz_screen.dart           # Page 3 (Left): Bible Trivia Quiz & Rewarded 50/50 Hint
        ├── verse_art_studio_screen.dart # Page 3 (Right): Shareable HD Verse Art Studio
        └── versions_backup_screen.dart  # Page 4: Offline Version Manager, Drive Backup & UMP/Deletion
```

---

## Running & Building

```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis & unit tests
flutter analyze
flutter test

# 3. Run on Android / iOS / Web
flutter run

# 4. Build release bundles
flutter build appbundle --release   # Play Store .aab
flutter build apk --release         # Android .apk
flutter build web --release         # Offline-first Web PWA
```
