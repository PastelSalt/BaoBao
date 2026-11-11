# CODEMAP

Index of the repository as it exists now. Planned work lives in `PLAN-A-00-111126.md`, not here. Update this file whenever structure, responsibilities, navigation, dependencies, or data flow change (`INSTRUCTIONS.md`).

Last verified against the tree: 2026-11-11.

## 1. Top level

| Path | What it is |
|------|------------|
| `README.md` | Project overview, setup, build commands. |
| `INSTRUCTIONS.md` | Repository rules for contributors and agents. |
| `PROJECT-SPECS.md` | Objectives, current state, known issues, roadmap. |
| `PLAN-A-00-111126.md` | Flutter migration and production-readiness plan. |
| `LOG.md` | Change log of actions taken in the repo. |
| `CODEMAP.md` | This file. |
| `docs/legacy/` | Four older reference docs (audio naming, conversation logic, dialog design, outfit system). May be stale; see its `README.md`. |
| `app/` | The only Gradle module: the Android application. |
| `build.gradle.kts`, `settings.gradle.kts`, `gradle.properties` | Root Gradle configuration. One module, `:app`. |
| `gradle/libs.versions.toml` | Version catalog for plugins and libraries. |
| `gradle/wrapper/`, `gradlew`, `gradlew.bat` | Gradle wrapper. |
| `.gitignore` | Ignores build output, IDE state (`.idea/`, `.kotlin/`), JVM crash logs, and Flutter tool output. |

## 2. App module

```
app/
├── build.gradle.kts            Module build: SDK levels, ViewBinding, dependencies
├── proguard-rules.pro          Empty apart from template comments (minify is off)
└── src/main/
    ├── AndroidManifest.xml     Activities, VIBRATE permission, launcher
    ├── java/com/example/baobao/  Kotlin source (section 3)
    └── res/                    Layouts, drawables, audio, fonts (section 5)
```

Build facts: namespace and application ID `com.example.baobao`, `minSdk` 24, `compileSdk`/`targetSdk` 36, version `1.0` (code 1), Java 11 target, release build not minified. There is no test source set.

## 3. Kotlin source — `app/src/main/java/com/example/baobao/`

32 files, about 8,600 lines. All UI is Activity + ViewBinding; there are no ViewModels or dependency injection. Shared state lives in Kotlin `object` singletons.

### Root package — screens

| File | Responsibility |
|------|----------------|
| `AuthActivity.kt` | Login, sign-up, and guest entry. Shows a random BaoBao line with voice. Routes to the tutorial on first run, otherwise the main screen. Contains a **debug dialog that lists all accounts**. |
| `MainActivity.kt` | Home screen. Wires up the four helper classes from `coreoperations`, shows the time-based greeting, starts conversations, applies the selected outfit, background, and music. |
| `ShopActivity.kt` | Shop for music, outfit, and backgrounds. Prices are hard-coded here. |

### `additionals/` — transitional screens

| File | Responsibility |
|------|----------------|
| `SecondSplashActivity.kt` | Launcher activity. Builds its layout in code, shows the studio logo, then goes to `AuthActivity` or `MainActivity` depending on session state. |
| `LoadingActivity.kt` | Animated loading card shown between screens. `startWithTarget(activity, target, delay)` is the app's de facto navigation call. |

### `audio/`

| File | Responsibility |
|------|----------------|
| `SoundManager.kt` | Singleton. One looping `MediaPlayer` for background music, one for the click effect. Reads volumes from SharedPreferences. |
| `VoiceManager.kt` | Singleton. Plays one voice clip at a time. Resolves clips **by name at runtime** (`resources.getIdentifier`), so voice files have no compile-time references. Holds the node-ID → clip-number maps for each mood. |

### `conversation/`

| File | Responsibility |
|------|----------------|
| `ConversationNode.kt` | `ConversationNode` (id, mood, line, options, loop-point flag, feature nudge) and `UserOption` (text, next node, mood effect). |
| `ConversationManager.kt` | Singleton holding **all dialogue content in code**: ten simple script pools (sign-up, login, shop, settings, claw machine, self-care, affirmations, jokes, goodbye, greetings) and six node trees. Node counts: happy 11, okay 13, sad 16, anxious 15, tired 16, intervention 8 (79 total). |

### `coreoperations/` — main-screen helpers and shared UI

| File | Responsibility |
|------|----------------|
| `BaseActivity.kt` | Base for screens with music. Plays `getBgmResource()` on resume, pauses on pause. Default is `0` (no music); `ShopActivity` and `ClawMachineActivity` override it, `MainActivity` manages its own track. |
| `ConversationController.kt` | Runs a conversation on the main screen: picks the start node (or the intervention tree if `InterventionManager` says so), renders choices, applies mood effects, saves the path, returns at loop points. |
| `NavigationHandler.kt` | Main-screen buttons: shop, claw machine, settings, customise, and the idle "quick action" buttons (joke, affirmation, self-care, check-in). |
| `DialogManager.kt` | Builds the settings, customise, and mood-selection dialogs. Settings also hosts logout and tutorial replay. |
| `UIStateManager.kt` | Main-screen status bar: currency, mood, claw-machine tries and timer. Maps music keys to raw resources. |
| `CharacterImageManager.kt` | Singleton mapping outfit × emotion to a character drawable. |
| `BackgroundManager.kt` | Singleton mapping background ID to a drawable. |
| `AnimationManager.kt` | Singleton library of view animations (entrances, button press, dialog, character emotion change). |
| `TypewriterTextView.kt` | Custom `TextView` that reveals text character by character. Used in `activity_main.xml`. |

### `database/` — Room and session

| File | Responsibility |
|------|----------------|
| `AppDatabase.kt` | Room database `baobao_database`, version 5, entities `UserData` and `Purchase`. Uses `fallbackToDestructiveMigration()` — **a schema change deletes all user data**. |
| `UserData.kt` | Table `user_data`: credentials, currency (starts at 3000), owned and selected music/theme/outfit/background (comma-separated strings), mood history (JSON string), emotional weight, intervention state, conversation path. |
| `Purchase.kt` | Table `purchases`: item type, ID, name, cost, date. **Has no user ID column.** |
| `UserDao.kt` | Queries for both tables. |
| `UserRepository.kt` | Auth (SHA-256 hash compare), guest accounts, currency, purchases, selections. Every operation exists twice: once taking a `userId`, once reading it from `SessionManager`. |
| `SessionManager.kt` | Singleton. Current user ID, username, and guest flag in SharedPreferences file `BaoBaoSession`. |

### `games/`

| File | Responsibility |
|------|----------------|
| `ClawMachineActivity.kt` | The whole mini-game in one 1,200-line Activity: state machine (idle → moving → dropping → lifting → returning → completed), prize randomisation, hit test, combo multiplier, tries and refill timer, daily try purchases, statistics, haptics, result dialog. |

### `intervention/`

| File | Responsibility |
|------|----------------|
| `InterventionManager.kt` | Pure logic. Emotional weight change per mood (happy −3, okay −2, sad +1, tired +1, anxious +2; clamped 0–10). Triggers when weight ≥ 4 **and** (≥ 2 consecutive negative check-ins **or** 2 of the last 3 moods negative), with a 24-hour cooldown. **`calculateNewEmotionalWeight`, `calculateConsecutiveNegativeCycles`, and `resetInterventionIfImproved` have no callers**, so the trigger condition is never met. |
| `ResourcesActivity.kt` | Helpline screen. Dials 988, SAMHSA, and NAMI; texts the Crisis Text Line; opens a mentalhealth.gov page. United States only. |

### `models/`

| File | Responsibility |
|------|----------------|
| `MoodEntry.kt` | `MoodEntry` (mood, timestamp, weight) and the `PrimaryMood` enum. |

### `optimization/`

| File | Responsibility |
|------|----------------|
| `CacheManager.kt` | In-memory cache of currency and claw tries valid for 2 seconds. Used by `UIStateManager` and `ClawMachineActivity`. |
| `MemoryOptimizer.kt` | Helpers for safely posting to and cleaning up `Handler`s. |

### `tutorial/`

| File | Responsibility |
|------|----------------|
| `TutorialManager.kt` | Tutorial step definitions and text, per-screen quick guides, completion state in SharedPreferences. |
| `TutorialActivity.kt` | Step-through tutorial screen with next, back, and skip. |

## 4. Navigation

```
SecondSplashActivity (launcher)
  ├─ not logged in ─▶ AuthActivity ─▶ LoadingActivity ─▶ TutorialActivity (first run) ─▶ MainActivity
  └─ logged in ────▶ MainActivity

MainActivity
  ├─ tap BaoBao / check-in ─▶ mood dialog ─▶ conversation (in place)
  │                                         └─ intervention tree ─▶ ResourcesActivity
  ├─ shop button ───────────▶ LoadingActivity ─▶ ShopActivity
  ├─ claw button ───────────▶ LoadingActivity ─▶ ClawMachineActivity
  ├─ settings dialog ───────▶ TutorialActivity (replay) / AuthActivity (logout)
  └─ customise dialog ──────▶ ShopActivity (via LoadingActivity)
```

All activities are declared in `AndroidManifest.xml`. Only the splash is exported. Splash, claw machine, and tutorial are locked to portrait.

## 5. Resources — `app/src/main/res/`

| Folder | Contents |
|--------|----------|
| `layout/` | One layout per screen (`activity_auth`, `_main`, `_shop`, `_claw_machine`, `_loading`, `_resources`, `_tutorial`) and three dialogs (`dialog_settings`, `_customize`, `_mood_selection`). All are consumed through ViewBinding, so there are no `R.layout` references in code. |
| `drawable/` | Character art as PNG (`mainscreen_outfit{1,2}_fullbody_{happy,hello,sad,tired}`, five `*face_default` mood icons, logos, loading art) and XML shapes for the bamboo UI, backgrounds, icons, and prizes. |
| `raw/` | 142 voice clips (`.aac`) and 6 music/effect files (`.mp3`). See the table below. |
| `anim/` | 12 view animations used by the activity and dialog transition styles in `themes.xml`. |
| `font/` | Quicksand in five weights. `quicksand.xml` currently maps **every** weight to `quicksand_bold.ttf`; the other four weight files are unused at the moment and kept for the migration. |
| `mipmap-*/` | Launcher icons (adaptive icon uses `@drawable/applogo` on white). |
| `values/`, `values-night/` | Colours, the single `app_name` string, themes and animation styles. Almost all user-facing text is hard-coded in layouts and Kotlin, not in `strings.xml`. |
| `xml/` | Default backup and data-extraction rules. |

### Audio naming (`raw/`)

| Prefix | Count | Used for |
|--------|-------|----------|
| `a_` | 5 | Sign-up lines |
| `b_` | 5 | Login lines |
| `c_` | 5 | Shop lines |
| `d_` | 5 | Settings lines |
| `e_` | 10 | Self-care lines |
| `f_` | 10 | Affirmations |
| `g_` | 10 | Jokes |
| `g_greetings_` | 3 | Morning, afternoon, evening greeting |
| `h_` | 5 | Claw-machine lines |
| `i_` | 5 | Goodbye lines |
| `h_happy_` | 11 | Happy tree nodes |
| `o_okay_` | 13 | Okay tree nodes |
| `s_sad_` | 16 | Sad tree nodes |
| `x_anxious_` | 15 | Anxious tree nodes |
| `t_tired_` | 16 | Tired tree nodes |
| `int_` | 8 | Intervention tree nodes |
| `main_bgm_kakushigoto`, `main_bgm_little`, `main_bgm_ordinary_days` | 3 | Main-screen music (default plus two shop unlocks) |
| `shop_bgm`, `clawmachine_bgm`, `click_sfx` | 3 | Screen music and the click effect |

Because voice clips are looked up by name, **renaming or deleting a clip fails silently at runtime** rather than at build time.

## 6. Data storage

| Store | Keys / tables | Scope |
|-------|---------------|-------|
| Room `baobao_database` | `user_data`, `purchases` | `user_data` is per account. `purchases` is shared by all accounts on the device. |
| SharedPreferences `BaoBaoSession` | current user ID, username, logged-in flag, guest flag | Device |
| SharedPreferences `BaoBaoPrefs` | `bgm_volume`, `sfx_volume`, `voice_volume`, `voice_enabled`; claw machine tries, refill time, daily purchases, statistics | Device (not per account) |
| SharedPreferences `BaoBaoTutorialPrefs` | completion flag, current step, learned features | Device |

## 7. Key data flows

**Mood check-in → conversation.** `MainActivity` opens the mood dialog (`DialogManager`) → `ConversationController.startConversation(mood)` loads `UserData` (it does **not** record the check-in — mood history, emotional weight, and the negative counter are not updated), asks `InterventionManager.shouldTriggerIntervention` (always false in practice), and picks either the mood tree or the intervention tree from `ConversationManager` → each node is rendered with `TypewriterTextView`, voiced through `VoiceManager.playNodeVoice`, and its options become buttons → an option leads to another node, a loop point (conversation ends, path saved to `UserData`), or `show_resources_screen` (`ResourcesActivity`).

**Currency.** Earned in `ClawMachineActivity` (`UserRepository.addCurrency`), spent in `ShopActivity` and on extra claw tries (`spendCurrency`). `CacheManager` holds a short-lived copy for the main-screen status bar and is invalidated after writes.

**Customisation.** `ShopActivity` records ownership in `UserData` → the customise dialog (`DialogManager`) writes the selection → `MainActivity` re-applies it through `CharacterImageManager`, `BackgroundManager`, and `SoundManager`.

## 8. Dependencies

Declared in `gradle/libs.versions.toml` and `app/build.gradle.kts`.

| Dependency | Version | Use |
|------------|---------|-----|
| Android Gradle Plugin | 8.9.1 | Build |
| Kotlin | 2.0.21 | Language |
| KSP | 2.0.21-1.0.28 | Room annotation processing |
| `androidx.core:core-ktx` | 1.17.0 | Core extensions |
| `androidx.appcompat` | 1.7.1 | Activities |
| `com.google.android.material` | 1.13.0 | Material components |
| `androidx.constraintlayout` | 2.2.1 | Layouts |
| `androidx.room` (runtime, ktx, compiler) | 2.6.1 | Database |
| `kotlinx-coroutines-android` | 1.7.3 | Async |
| `androidx.lifecycle:lifecycle-runtime-ktx` | 2.7.0 | `lifecycleScope` |
