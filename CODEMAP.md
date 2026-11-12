# CODEMAP

Index of the repository as it exists now. Planned work lives in `PLAN-A-00-111126.md`, not here. Update this file whenever structure, responsibilities, routes, dependencies, or data flow change (`INSTRUCTIONS.md`).

Last verified against the tree: 2026-11-11.

## 1. Top level

| Path | What it is |
|------|------------|
| `README.md`, `INSTRUCTIONS.md`, `PROJECT-SPECS.md`, `PLAN-A-00-111126.md`, `LOG.md`, `CODEMAP.md` | Project documentation. |
| `docs/RELEASE.md`, `docs/PRIVACY.md` | Release guide; draft privacy policy. |
| `pubspec.yaml`, `pubspec.lock` | Dependencies, assets, fonts. The `hooks` section selects the encrypted SQLite build. |
| `analysis_options.yaml` | Lint rules (strict casts, inference, raw types; package imports only). |
| `build.yaml` | drift code-generation options and schema snapshot locations. |
| `l10n.yaml` | Localisation generator settings. |
| `lib/` | App source (section 2). |
| `test/` | Tests (section 6). |
| `assets/` | Content, audio, images, fonts (section 5). |
| `tool/` | `validate_content.dart` (content check), `check_coverage.dart` (coverage gate), `make_audio.py` (music and effects generator). |
| `drift_schemas/` | Snapshot of each database schema version, for migration tests. |
| `android/`, `ios/` | Platform projects. |
| `.github/workflows/ci.yml` | CI: format, generated-code freshness, analysis, content validation, tests, domain coverage ≥ 90%, Android build; unsigned iOS build on macOS. |

## 2. Source — `lib/`

60 hand-written Dart files, about 6,900 lines. Feature-first: each feature folder may contain `domain/` (pure Dart rules, no Flutter imports), `data/` (database access), `application/` (controllers and providers), and `presentation/` (widgets).

### Entry and app shell

| File | Responsibility |
|------|----------------|
| `main.dart`, `main_dev.dart` | Entry points for the `prod` and `dev` flavours. Both call `bootstrap`. |
| `bootstrap.dart` | Startup: loads preferences and content, creates or reads the database key, opens the encrypted database, configures audio, checks the remembered profile still exists, locks the app if the lock is on. Shows `StartupErrorApp` with a retry if anything fails. |
| `app/app.dart` | `BaoBaoApp`: theme, localisation, router. Pauses sound and tracks time away when backgrounded. Chooses the music for the screen on top (`_syncMusic`). Pushes settings changes to the audio director. |
| `app/router.dart` | Routes, the `guard` redirect rule, and `musicFor` (which track each route plays). |
| `app/theme/app_colors.dart` | Palette and a WCAG contrast calculation. |
| `app/theme/app_theme.dart` | Material theme and Quicksand typography. |

### `core/` — shared infrastructure

| File | Responsibility |
|------|----------------|
| `providers.dart` | Riverpod providers: database, content, audio director, clock, repositories, and the active profile's streams (profile, balance, selections, owned items, latest mood). |
| `settings/app_settings.dart` | `AppSettings` and `SettingsController`: volumes, voice, reduced motion, claw tap mode, consent version, active profile, app lock, tutorial seen, help country. Stored in shared_preferences. |
| `content/app_content.dart` | `AppContent.load`: reads all content JSON through an `AssetReader`, so it works from the asset bundle and from disk. |
| `content/content_models.dart` | `VoicedLine`, `LinePool` (no immediate repeats), `ScriptLibrary`, `Helpline*`, `TutorialStep`, `DayPart`. |
| `content/content_validator.dart` | Graph checks for a conversation tree: targets exist, every node reachable, every node can reach an ending. |
| `content/content_audit.dart` | Cross-checks content against asset files. Separates errors from release blockers (unverified helplines, unlicensed media). |
| `database/tables.dart` | drift table definitions (section 4). |
| `database/app_database.dart` | `AppDatabase`, schema version, foreign keys on, and `adjustBalance` (the only way a wallet changes; always writes a ledger entry). |
| `database/database_opener.dart` | Key creation, encrypted open, refusal to run without a cipher, and moving aside a file that cannot be read with the key. |
| `audio/audio_channel.dart` | `AudioChannel` interface, `JustAudioChannel`, `SilentChannel`. Only the music channel claims audio focus. |
| `audio/audio_director.dart` | Coordinates music, voice, and effects: ducking under voice, one voice line at a time, silence in the background, failures swallowed and reported. |
| `security/app_lock.dart` | `DeviceAuthenticator` (local_auth) and `AppLockController` (locks after 60 seconds away). |
| `security/secure_key_store.dart` | Database key in Android Keystore / iOS Keychain. |
| `links/link_opener.dart` | Opens `tel:`, `sms:`, and web links through url_launcher. |
| `widgets/` | `BambooFrame`, `BambooButton`, `BambooDialog`, `SpeechBubble`, `TypewriterText`, `CharacterView`, `AppBackground`, `LoadingOverlay`, `ScreenScaffold`, `StarAmount`, and `reduceMotion`. |

### `features/`

| Feature | Files | Responsibility |
|---------|-------|----------------|
| `onboarding` | `presentation/onboarding_screen.dart` | Welcome, disclaimer and age confirmation, name, optional app lock. Saves nothing until the last step. |
| `app_lock` | `presentation/unlock_screen.dart` | Shown instead of the app while locked. |
| `home` | `application/home_controller.dart`, `presentation/home_screen.dart` | What BaoBao says and does: greeting, quick actions, check-in, conversation, leaving a chat. The screen shows status, speech bubble, character, and either replies or the idle buttons. |
| `mood` | `domain/mood.dart`, `emotional_state.dart`, `mood_tracker.dart`; `data/mood_repository.dart`; `presentation/mood_sheet.dart` | Moods and their weights; how check-ins and choices change the emotional state; recording a check-in and deciding on intervention in one transaction; the "How are you feeling?" sheet. |
| `intervention` | `domain/intervention_policy.dart`, `presentation/resources_screen.dart` | When to intervene (threshold, pattern, cooldown); the helpline screen with region picker and a fallback when a link cannot be opened. |
| `conversation` | `domain/conversation_models.dart`, `conversation_session.dart`; `data/conversation_repository.dart` | Tree, node, and option models; an immutable session that advances on each choice; saving where a conversation got to. |
| `economy` | `domain/catalog.dart`, `purchase_rules.dart`; `data/economy_repository.dart` | Catalogue and slots; whether a purchase is allowed; atomic purchase, ownership, and equipping. |
| `shop` | `presentation/shop_screen.dart` | Buying with confirmation, music preview. |
| `customization` | `presentation/customize_sheet.dart`, `item_card.dart` | Switching between owned items from home, with the change visible behind the sheet. |
| `claw_machine` | `domain/claw_game.dart`, `claw_tries.dart`; `data/claw_repository.dart`; `application/claw_controller.dart`, `claw_tries_provider.dart`; `presentation/claw_machine_painter.dart`, `claw_machine_screen.dart` | The game state machine and prize rules; try refills and daily purchases; persistence and payouts; the controller that ties a round to tries, voice, and payout; the drawn machine; the screen. |
| `profiles` | `data/profile_repository.dart` | Create (with starting balance, defaults, full tries), rename, delete with cascade. |
| `settings` | `presentation/settings_screen.dart` | Sound, accessibility, profiles, privacy, about. Holds `appVersion`. |
| `tutorial` | `presentation/tutorial_screen.dart` | The tour, driven by content. |

### `l10n/`

`app_en.arb` is the source of all interface text. `app_localizations*.dart` are generated.

## 3. Routes

| Path | Screen | Music |
|------|--------|-------|
| `/` | `HomeScreen` | The selected track |
| `/onboarding` | `OnboardingScreen` | The default track |
| `/unlock` | `UnlockScreen` | None |
| `/shop` | `ShopScreen` | Shop track, or a previewed track |
| `/claw` | `ClawMachineScreen` | Claw machine track |
| `/settings` | `SettingsScreen` | The selected track |
| `/resources` | `ResourcesScreen` | The selected track |
| `/tutorial` | `TutorialScreen` | The selected track |

Guard order: not onboarded → `/onboarding`; locked → `/unlock`; otherwise onboarding and unlock redirect to `/`. The mood check-in and style picker are bottom sheets on home, not routes.

## 4. Data storage

### Encrypted database (`baobao.sqlite` in the app support directory)

Schema version 1. Every table except `profiles` has `profile_id` with `ON DELETE CASCADE`.

| Table | Holds |
|-------|-------|
| `profiles` | Name, created and last-active times. |
| `wallets` | Star balance; a `CHECK` keeps it at zero or above. |
| `ledger_entries` | Every balance change with a reason (`welcome`, `purchase:<id>`, `claw:try`, `claw:win`). |
| `mood_entries` | One row per check-in. |
| `emotional_states` | Weight, consecutive negative count, last intervention time. |
| `owned_items` | Catalogue items owned. |
| `selections` | The equipped item per slot. |
| `conversation_progress` | Tree, last node, and path of the most recent conversation. |
| `claw_states` | Tries, next refill time, purchases today and for which day. |
| `claw_stats` | Plays, wins, earnings, best win. |

### Other storage

| Store | Contents |
|-------|----------|
| shared_preferences | Volumes, voice enabled, reduced motion, claw tap mode, consent version, active profile ID, app lock enabled, tutorial seen, help country. Nothing sensitive. |
| Platform keystore | The database key (`baobao.db.key.v1`). |

Android backups are disabled in the manifest and in `data_extraction_rules.xml`.

## 5. Assets

| Path | Contents |
|------|----------|
| `assets/content/conversations/en/*.json` | Six conversation trees. Option targets are node IDs, `@end`, or `@resources`. |
| `assets/content/scripts/en.json` | Line pools (welcome, welcome back, shop, settings, self-care, affirmations, jokes, goodbye), time-of-day greetings, claw-machine lines. |
| `assets/content/catalog.json` | Starting balance and all items with slot, price, asset, and licence. |
| `assets/content/helplines.json` | Helplines by country plus a worldwide fallback. Each has `verifiedOn`, currently null. |
| `assets/content/tutorial/en.json` | Tour steps. |
| `assets/audio/voice/en/*.m4a` | 142 voice clips, named by the `voice` field in content. |
| `assets/audio/music/*.m4a` | Five generated tracks: three home tracks, shop, claw machine. |
| `assets/audio/sfx/*.m4a` | Click, win, miss. |
| `assets/images/character/<outfit>/{hello,happy,sad,tired}.webp` | Character art per outfit. |
| `assets/images/moods/*.webp` | Mood faces for the check-in sheet. |
| `assets/images/backgrounds/*.svg` | Home backgrounds. |
| `assets/images/brand/` | App icon source, loading art, wordmark, BaoBao mark. |
| `assets/fonts/Quicksand-*.ttf` | Five weights, 300–700. |

Adding a language means adding `conversations/<code>/`, `scripts/<code>.json`, `tutorial/<code>.json`, `audio/voice/<code>/`, an ARB file, the asset folders in `pubspec.yaml`, and the code in `AppContent.supportedLanguages`.

## 6. Tests — `test/`

223 tests. `flutter test` runs them all.

| Area | Files | Covers |
|------|-------|--------|
| Domain | `features/*/…_test.dart` for mood, intervention, conversation, economy, claw game, claw tries | Rules, at 95.9% line coverage of `domain/` folders. |
| Content | `core/content/content_test.dart` | The shipped content: structure, voice references both ways, catalogue assets, helpline lookup, prices. |
| Database | `core/database/repositories_test.dart`, `database_opener_test.dart` | Per-profile isolation, atomic purchases, cascade delete, encryption on disk, unreadable file handling. |
| Core | `core/audio`, `core/settings`, `core/security`, `app/router_guard_test.dart`, `app/theme_test.dart` | Audio coordination, settings persistence, lock timing, routing rules, colour contrast. |
| Widgets | `core/widgets/*` | Typewriter, button semantics and focus, shared widget goldens at 1× and 2× text. |
| Flows | `features/onboarding`, `home`, `intervention`, `shop`, `settings`, `claw_machine` | Whole-app journeys through the real router, database, and content with recorded audio and a fixed clock. |
| Goldens | `app/key_screens_golden_test.dart`, `features/claw_machine/claw_painter_golden_test.dart` | Home, conversation, shop, settings, and resources at 1× and 2× text; the drawn claw machine. |
| Support | `support/app_harness.dart`, `support/test_database.dart` | `Harness` (in-memory database, real content, fake audio, fixed clock), `pumpApp`, `settle`, font loading. |

Database work needs real time, so flow tests call `settle` after actions. Do not close the database or write to it through `tester.runAsync` while screens are listening: it never completes.

## 7. Key data flows

**Check-in → conversation.** `HomeScreen` shows `showMoodSheet` → `HomeController.checkIn` → `MoodRepository.recordCheckIn` inserts the entry, applies `MoodTracker.checkIn`, asks `InterventionPolicy.shouldIntervene`, stamps the intervention time if needed, all in one transaction → the controller starts a `ConversationSession` on the mood's tree or the intervention tree → each node's line goes to `TypewriterText` and its clip to `AudioDirector.speak` → `choose` applies any mood effect and advances; `@end` saves progress and says goodbye; `@resources` opens `ResourcesScreen` and leaves the conversation in place.

**Stars.** `ProfileRepository.create` grants the starting balance. `ClawRepository.recordResult` pays out wins. `EconomyRepository.purchase` and `ClawRepository.buyTry` spend. All go through `AppDatabase.adjustBalance` inside the same transaction as what the stars buy.

**Style.** `ShopScreen` buys and equips; `showCustomizeSheet` switches between owned items. Both write `selections`; `selectionsProvider` updates the home background, outfit, and (through `BaoBaoApp._syncMusic`) the music.

**Claw round.** Button press → `ClawController.press` spends a try, then `ClawGame.startMoving` → release → `drop` → the screen's ticker calls `advance` → at the bottom `ClawGame` decides the catch → when the round finishes the controller records the result, plays the effect and line, and after a pause calls `nextRound`.

## 8. Dependencies

Exact versions are in `pubspec.lock`.

| Package | Use |
|---------|-----|
| `flutter_riverpod` | State and dependency injection |
| `go_router` | Navigation |
| `drift`, `sqlite3` | Database (built with SQLite3 Multiple Ciphers via `hooks` in `pubspec.yaml`) |
| `flutter_secure_storage` | Database key |
| `shared_preferences` | Settings |
| `path_provider`, `path` | Database location |
| `just_audio`, `audio_session` | Audio |
| `local_auth` | App lock |
| `url_launcher` | Helpline links |
| `flutter_svg` | Backgrounds |
| `intl`, `flutter_localizations` | Localisation |
| `clock` | Injectable time |
| `drift_dev`, `build_runner` (dev) | Database code generation |
| `flutter_lints` (dev) | Lint base |
