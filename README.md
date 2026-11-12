# BaoBao

BaoBao is a pocket emotional-support companion. A panda character asks how you feel, talks you through a short voiced conversation for that mood, and gently points you to real help when your check-ins have been low for a while. A claw-machine mini-game earns stars that you spend on music, outfits, and backgrounds.

BaoBao is a comfort app. It is **not** therapy, diagnosis, or a crisis service.

**Status:** version `0.5.0`, built with Flutter for Android and iOS. Feature-complete against the original prototype and covered by automated tests, but **it has not yet been run on a real device or emulator**, and it is not ready for a public release. See [Known limitations](#known-limitations).

## Documentation

| File | Purpose |
|------|---------|
| `INSTRUCTIONS.md` | Rules for anyone (human or agent) working in this repo. Read first. |
| `PROJECT-SPECS.md` | What BaoBao is for, what it does, what is left to do. |
| `CODEMAP.md` | Index of the code: structure, responsibilities, data flow. |
| `PLAN-A-00-111126.md` | The migration and production-readiness plan, with current status. |
| `LOG.md` | Chronological record of every change made to the repo. |
| `docs/RELEASE.md` | How to build and sign a release, and store-listing status. |
| `docs/PRIVACY.md` | Draft privacy policy. |

## What the app does

- **Profiles:** local profiles with a name, no passwords and no accounts. Optional app lock using the device's fingerprint, face, or PIN.
- **Mood check-in:** five moods (happy, okay, sad, anxious, tired).
- **Conversations:** 79 authored dialogue nodes across five mood trees and an intervention tree, with typewriter text and 142 voice clips. A chat can be ended at any point.
- **Care logic:** check-ins adjust an emotional weight. After a sustained low stretch BaoBao switches to an intervention conversation that leads to helplines. It will not repeat within 24 hours.
- **Get help:** helplines for the person's region with call, text, and web actions, always reachable from Settings.
- **Claw machine:** five tries that refill over time, random prizes, win streak multiplier, extra tries for stars.
- **Shop and style:** music, outfits, and backgrounds, bought with stars and switched from the home screen.
- **Settings:** volumes, voice on/off, reduced motion, tap-instead-of-hold for the claw machine, app lock, multiple profiles, delete my data.
- **Privacy:** everything stays on the device in an encrypted database. No network access is used.

## Requirements

- Flutter 3.47.9 (stable) — the version CI pins
- Android: Android SDK with platform 36, JDK 17
- iOS: a Mac with Xcode (the iOS app has not been built yet)

## Run

```bash
flutter pub get
```

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

The `dev` flavour installs as "BaoBao Dev" (`com.moekoworks.baobao.dev`) alongside the production app. On iOS there is a single target, so omit `--flavor`.

## Test and check

```bash
flutter test
```

```bash
flutter analyze
```

```bash
dart run tool/validate_content.dart
```

`flutter test --update-goldens` regenerates the reference screenshots under `test/**/goldens/`. They were generated on Linux; on another operating system small rendering differences are expected.

## Generated code

Commit the output of these whenever their inputs change. CI fails if they are out of date.

| Command | Regenerates | When |
|---------|-------------|------|
| `dart run build_runner build` | `lib/core/database/app_database.g.dart` | After editing `tables.dart` or `app_database.dart` |
| `flutter gen-l10n` | `lib/l10n/app_localizations*.dart` | After editing `lib/l10n/app_en.arb` |
| `dart run drift_dev make-migrations` | `drift_schemas/` and migration tests | After raising `schemaVersion` |
| `python3 tool/make_audio.py` | `assets/audio/music/`, `assets/audio/sfx/` | After changing the music generator |

## Build a release

See `docs/RELEASE.md`.

## Tech stack

| Area | Choice |
|------|--------|
| Framework | Flutter, Dart |
| State and dependency injection | Riverpod |
| Navigation | go_router |
| Database | drift on SQLite, encrypted with SQLite3 Multiple Ciphers; key in the platform keystore |
| Settings | shared_preferences |
| Audio | just_audio and audio_session (three channels: music, voice, effects) |
| App lock | local_auth |
| Localisation | Flutter `gen-l10n` with ARB files; dialogue in per-language JSON |
| CI | GitHub Actions (`.github/workflows/ci.yml`) |

## Repository layout

```
lib/            App source (see CODEMAP.md)
test/           Unit, widget, and golden tests
assets/         Content JSON, voice, music, images, fonts
tool/           Content validator, coverage gate, audio generator
android/, ios/  Platform projects
drift_schemas/  Database schema snapshots for migration tests
docs/           Release guide and privacy policy draft
```

## Known limitations

- **Never run on a device.** All verification is automated tests plus successful Android builds. Audio playback, the biometric prompt, dialling, the splash screen, and real-world performance are untested.
- **iOS has never been built.** The project and configuration exist; nobody has compiled it.
- **Helplines are unverified.** Every entry in `assets/content/helplines.json` must be checked by a person. The release content check fails until they are.
- **Only United States helplines** are included, plus international directories for everyone else.
- **Music is computer-generated** by `tool/make_audio.py` and has not been listened to by a person.
- **No anxious or okay character art.** Those moods reuse the sad and hello poses.
- **No crash reporting**, and CI has not run yet on GitHub.
- **Not reviewed** by a clinician or a lawyer.
