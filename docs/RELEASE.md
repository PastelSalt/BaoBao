# Releasing BaoBao

How to produce release builds, and what still has to happen before a public release. See `PLAN-A-00-111126.md` §10 for the full readiness checklist.

## Before you start

1. Content must pass the release check, which fails on unverified helplines:

   ```bash
   dart run tool/validate_content.dart --release
   ```

   To clear a helpline, check its details against the organisation's own website and set `verifiedOn` to that date in `assets/content/helplines.json`.

2. Raise `version` in `pubspec.yaml` and `appVersion` in `lib/features/settings/presentation/settings_screen.dart` together.

## Android

Release builds are signed with the key described in `android/key.properties`. That file and the keystore must never be committed (both are in `.gitignore`).

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Without `key.properties` the build falls back to the debug key so it can still be installed locally, but such a build cannot be uploaded to Google Play.

App bundle for Google Play:

```bash
flutter build appbundle --release --flavor prod -t lib/main.dart --obfuscate --split-debug-info=build/symbols
```

APKs for direct installation:

```bash
flutter build apk --release --flavor prod -t lib/main.dart --split-per-abi
```

Keep `build/symbols` for each release: it is needed to read obfuscated stack traces.

## iOS

Not yet built or signed. On a Mac with Xcode:

```bash
flutter build ipa --release -t lib/main.dart --obfuscate --split-debug-info=build/symbols
```

Outstanding iOS work:

- Set the development team and bundle identifier (`com.moekoworks.baobao`) in Xcode.
- Add `dev` and `prod` schemes if a separate development app is wanted. Android has both flavours; iOS has one target.
- Exclude the database file from iCloud backup, to match Android where backups are off.

## Store listings

| Item | State |
|------|-------|
| Privacy policy | Draft in `docs/PRIVACY.md`; needs legal review and a public URL |
| Google Play Data safety form | Not started. The honest answer today is "no data collected or shared" |
| App Store privacy labels | Not started. Same answer |
| Content rating questionnaires | Not started |
| Screenshots and descriptions | Not started. `test/app/goldens/` has current screen images |
| Health-app policy review (both stores) | Not started |
