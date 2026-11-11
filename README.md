# BaoBao

BaoBao is an emotional-support companion app. A panda character checks in on how you feel, talks you through a branching voiced conversation for that mood, and gently points you to professional help when your recent check-ins look consistently low. A claw-machine mini-game earns currency that you spend on music, outfits, and backgrounds.

**Status:** prototype (`b0.4.3`). The app is a native Android app written in Kotlin. A migration to Flutter is planned but **not started** — see `PLAN-A-00-111126.md`.

## Documentation

| File | Purpose |
|------|---------|
| `INSTRUCTIONS.md` | Rules for anyone (human or agent) working in this repo. Read first. |
| `PROJECT-SPECS.md` | Objectives, what exists today, known problems, and the roadmap. |
| `CODEMAP.md` | Index of the current code: structure, responsibilities, data flow. |
| `PLAN-A-00-111126.md` | Full plan for the Flutter migration and production hardening. |
| `LOG.md` | Chronological record of every change made to the repo. |
| `docs/legacy/` | Four older reference docs kept for the migration. May be stale. |

## What the app does today

- **Accounts:** local sign-up, login, and guest accounts stored on the device.
- **Mood check-in:** five moods (happy, okay, sad, anxious, tired).
- **Conversations:** 79 dialogue nodes across five mood trees plus an intervention tree, with typewriter text and 142 voice clips.
- **Care logic:** each check-in updates an emotional weight; past a threshold, BaoBao switches to an intervention conversation and a screen of helplines.
- **Claw machine:** timed tries, random prizes, combo multiplier, purchasable extra tries.
- **Shop and customisation:** two extra music tracks, one extra outfit, two extra backgrounds.
- **Settings and tutorial:** volume sliders for music, effects, and voice; a step-through tutorial.

## Requirements

- Android Studio (a version that supports Android Gradle Plugin 8.9.1)
- JDK 11 or newer
- Android SDK with platform 36 installed
- A device or emulator on Android 7.0 (API 24) or newer

## Build and run

Open the repository root in Android Studio and run the `app` configuration, or use the command line:

```bash
./gradlew assembleDebug
```

```bash
./gradlew installDebug
```

The debug APK is written to `app/build/outputs/apk/debug/`.

Run the unit tests:

```bash
./gradlew testDebugUnitTest
```

The only tests so far cover the intervention rules (`InterventionManagerTest`). Broader coverage is part of the migration plan.

## Tech stack

| Area | Choice |
|------|--------|
| Language | Kotlin 2.0.21 |
| UI | Android Views with ViewBinding, Material Components |
| Persistence | Room 2.6.1 (accounts, progress, purchases) and SharedPreferences (session, settings, claw machine state) |
| Async | Kotlin coroutines |
| Media | `MediaPlayer` for music, effects, and voice |
| Build | Gradle Kotlin DSL with a version catalog (`gradle/libs.versions.toml`) |

## Repository layout

```
app/                 Android application module (all source, layouts, and assets)
docs/legacy/         Older reference docs kept for the migration
gradle/              Gradle wrapper and version catalog
*.md                 Project documentation (see table above)
```

`CODEMAP.md` has the detailed breakdown.

## Known limitations

The prototype is not ready for release. The main gaps are listed in `PROJECT-SPECS.md` §5; the most important are:

- Passwords are stored as unsalted SHA-256 hashes, and a debug dialog on the login screen lists every account.
- The database wipes itself on any schema change.
- Purchases and claw-machine state are not separated per account.
- The helplines are United States numbers only.
- The licence status of the bundled music has not been confirmed.
- The application ID is still the placeholder `com.example.baobao`.
