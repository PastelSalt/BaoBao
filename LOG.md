# LOG

Chronological record of actions taken in this repository. Add new entries at the bottom. Each entry gives the date, the action, the affected paths, and the result (`INSTRUCTIONS.md`).

History before 2026-11-11 is summarised in `PROJECT-SPECS.md` §3 and is available in full through `git log`.

## 2026-11-11 — Repository cleanup and documentation baseline

Branch: `claude/fervent-cori-4u1jxv`. Starting point: commit `e5db25f` ("small update. b0.4.3"), 426 tracked files, about 85 MB.

### 1. Analysis

| Action | Result |
|--------|--------|
| Listed all tracked files and read the build config, manifest, and Kotlin source. | Native Android/Kotlin app; 75 generated status reports in the root; crash dumps and IDE state committed. |
| Searched for references to every class and resource (including ViewBinding class names and `getIdentifier` lookups). | Found the unused code and resources removed below. |
| Traced callers of `InterventionManager`. | **Found that mood check-ins are never recorded, so the intervention flow cannot trigger.** Documented in `PROJECT-SPECS.md` §5 problem 1. Not fixed in this change. |

### 2. Removed

| Paths | Reason |
|-------|--------|
| 71 root `*.md` status reports (for example `FINAL_PROJECT_SUMMARY.md`, `MODULE1_IMPLEMENTATION.md`, `CODEBASE_ANALYSIS*.md`, `*_FIX*.md`) | Redundant, overlapping, and in places inaccurate. Useful content consolidated into `PROJECT-SPECS.md` and `CODEMAP.md`. |
| `conversation_scripts.txt` | Duplicate of text in `ConversationManager.kt`. |
| `hs_err_pid12120.log`, `replay_pid12120.log` | JVM crash dumps (about 3 MB). |
| `.idea/`, `.kotlin/` | IDE and compiler state; now ignored. |
| `cpp_version/ClawMachine.h` | Empty file. |
| `app/src/main/cpp/` (`CMakeLists.txt`, `native-lib.cpp`) | Unused C++ template; nothing loads the library. |
| `app/src/test/`, `app/src/androidTest/` | Android Studio template example tests only. |
| `app/src/main/java/com/example/baobao/optimization/PerformanceMonitor.kt` | No callers. |
| `optimization/README.md`, `tutorial/README.md` (under the source tree) | Folded into `CODEMAP.md`. |
| `res/raw/main_bgm.wav` | 26 MB; only referenced as a default that every subclass overrode. |
| `res/layout/activity_second_splash.xml`, `res/layout/splash_second.xml` | Unused; the splash builds its layout in code. |
| `res/mipmap-anydpi-v26/app_icon.xml`, `ic_app_icon.xml` | Zero-byte files (invalid XML resources). |
| 10 drawables: `bamboo_button_frame`, `bamboo_game_area_bg`, `bg_pastel_blue_sky`, `claw_game_area_enhanced`, `drop_zone_bg`, `ic_claw_bamboo`, `ic_launcher_background`, `ic_launcher_foreground`, `prize_placeholder`, `speech_bubble_background` | No references. |
| 12 animations: `bounce_in`, `button_press`, `character_entrance`, `fade_scale_in`, `fade_scale_out`, `float_up_down`, `gentle_sway`, `pulse`, `shake`, `slide_in_down`, `slide_out_up`, `spin_scale` | No references. |

### 3. Moved

| From | To | Reason |
|------|----|--------|
| `AUDIO_FILE_NAMING_GUIDE.md`, `CONVERSATION_LOGIC_EXPLANATION.md`, `DIALOG_DESIGN_STANDARD.md`, `OUTFIT_SYSTEM_GUIDE.md` | `docs/legacy/` | Reference material needed for the Flutter migration. |

### 4. Edited

| Path | Change |
|------|--------|
| `app/build.gradle.kts` | Removed the `externalNativeBuild` (CMake) block, the unused Glide dependency and its KSP compiler, the test dependencies, and `testInstrumentationRunner`. |
| `gradle/libs.versions.toml` | Removed the JUnit and Espresso entries. |
| `app/src/main/java/com/example/baobao/coreoperations/BaseActivity.kt` | Default `getBgmResource()` now returns `0` instead of the deleted `R.raw.main_bgm`. No behaviour change: all three subclasses already override it. |
| `res/mipmap-anydpi-v26/ic_launcher.xml`, `ic_launcher_round.xml` | Removed a duplicated `</adaptive-icon>` closing tag that made both files invalid XML. |
| `.gitignore` | Rewritten: ignores `.idea/`, `.kotlin/`, crash logs, OS files, and Flutter tool output. |

### 5. Created

| Path | Purpose |
|------|---------|
| `README.md` | Project overview, setup, and build commands. |
| `INSTRUCTIONS.md` | Repository rules. |
| `CODEMAP.md` | Index of the current codebase. |
| `PROJECT-SPECS.md` | Objectives, feature specification, history, known problems, roadmap. |
| `PLAN-A-00-111126.md` | Flutter migration and production-readiness plan. |
| `LOG.md` | This file. |
| `docs/legacy/README.md` | Explains the four retained legacy docs and their known drift. |

### 6. Validation

| Check | Result |
|-------|--------|
| Parsed every XML file under `app/src/main/res/` and `AndroidManifest.xml`. | All well-formed. |
| Compared every `@drawable`, `@anim`, `@layout`, `@font`, `@mipmap`, `@raw` and `R.*` reference against the files present. | No dangling references. |
| Searched the Kotlin source for uses of removed classes and dependencies (`PerformanceMonitor`, `Glide`, `System.loadLibrary`, `external fun`). | None. |
| `./gradlew assembleDebug` | **Not run.** The environment has no Android SDK. |

### 7. Result and known limitations

- 426 → 307 tracked files; working tree about 85 MB → 56 MB.
- The Gradle build has not been run after these changes. Run `./gradlew assembleDebug` locally to confirm. The two launcher icon files and the two zero-byte mipmap files were invalid before this change, so the previous commit may not have built from a clean checkout either.
- No application behaviour was intentionally changed.
- The intervention flow remains unreachable (see `PROJECT-SPECS.md` §5). Fixing it is the first functional priority.
- The four unused Quicksand weight files in `res/font/` were kept on purpose for the migration.

## 2026-11-11 — Wire mood check-ins into intervention tracking

Branch: `claude/fervent-cori-4u1jxv`.

### 1. Problem

Selecting a mood started a conversation without recording the check-in. Mood history stayed empty, the consecutive-negative counter stayed at 0, and emotional weight could only fall, so `InterventionManager.shouldTriggerIntervention` was never true and the intervention tree and resources screen were unreachable.

### 2. Edited

| Path | Change |
|------|--------|
| `app/src/main/java/com/example/baobao/intervention/InterventionManager.kt` | Added `recordMoodCheckIn(userData, moodName, timestamp)`: appends a `{mood, timestamp, weight}` entry to the mood history (newest 50 kept; unreadable history is replaced), then applies the existing weight, consecutive-negative, and flag-reset rules. No thresholds changed. |
| `app/src/main/java/com/example/baobao/coreoperations/ConversationController.kt` | `startConversation` records and saves the check-in before asking whether to trigger the intervention. |
| `app/build.gradle.kts`, `gradle/libs.versions.toml` | Added test dependencies `junit` 4.13.2 and `org.json:json` 20240303. |

### 3. Created

| Path | Purpose |
|------|---------|
| `app/src/test/java/com/example/baobao/intervention/InterventionManagerTest.kt` | 12 unit tests: recording, trigger after two anxious check-ins, no trigger after one, sad/tired accumulation, cooldown, re-trigger after 24 hours, positive check-in effects, flag reset, weight bounds, history cap, corrupt history. |

### 4. Documentation updated

`PROJECT-SPECS.md` (sections 2.2, 2.4, 3, 4, 5 — the intervention problem removed and the list renumbered), `README.md`, `CODEMAP.md`, `PLAN-A-00-111126.md`.

### 5. Validation

| Check | Result |
|-------|--------|
| `gradle testDebugUnitTest assembleDebug` with Android SDK platform 36 and build-tools 35.0.0 | **Passed.** 12 tests, 0 failures. Debug APK built (about 64 MB). |

This is also the first successful build since the cleanup entry above, so it confirms that the cleanup did not break compilation or resource linking.

### 6. Known limitations

- Built with the system Gradle 8.14.3, not the wrapper (which pins 9.1.0). The wrapper build was not run.
- Not run on a device or emulator. The trigger is proven by unit tests on the rules, not by tapping through the app.
- Behaviour change: users will now see the intervention conversation after sustained negative check-ins (for example, Anxious twice in a row). Each conversation start counts as one check-in.
- `ConversationController.saveConversationState` still stores `currentMood = "intervention"` after an intervention conversation. This predates the change and does not affect the trigger rules.

## 2026-11-11 — Trim development rules in INSTRUCTIONS.md

| Path | Change | Result |
|------|--------|--------|
| `INSTRUCTIONS.md` | Removed three development rules that were pasted in from another project by mistake: "Prefer small, focused changes that preserve existing behavior", "Follow the conventions already used by the project", and the rule about not documenting `node_modules` or `dist` in `CODEMAP.md`. | Three development rules remain: inspect before editing, run the narrowest validation, report results in `LOG.md`. No code changed; no validation needed. |

Owner's direction recorded for future work: for the migration and other major changes, do not preserve the prototype's structure or conventions for their own sake. Replace them wherever a different approach is clearly better.
