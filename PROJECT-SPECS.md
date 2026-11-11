# PROJECT-SPECS

What BaoBao is for, what has been built, what is wrong with it, and where it is going. For the code index see `CODEMAP.md`; for the step-by-step migration see `PLAN-A-00-111126.md`.

Last updated: 2026-11-11.

## 1. Product

**BaoBao is a pocket emotional-support companion.** A friendly panda asks how you feel, responds with a short voiced conversation suited to that mood, and offers light activities. If your check-ins stay low, BaoBao gently suggests professional support and shows helplines.

BaoBao is a comfort and self-care app. It is **not** therapy, diagnosis, or a crisis service, and it must never present itself as one.

### Objectives

1. **Emotional check-in.** Make it effortless to say how you feel (five moods) and feel heard.
2. **Supportive conversation.** Respond with warm, choice-driven, voiced dialogue instead of free-text chat, so every line is authored and safe.
3. **Care escalation.** Notice sustained low mood and point to real help, without alarm and without nagging.
4. **Gentle engagement.** Give reasons to come back that are kind rather than compulsive: a mini-game, a currency, and cosmetic rewards.
5. **A consistent character.** One personality, one voice, one visual style (soft bamboo-green, rounded, Quicksand type).

### Design principles

- Every line BaoBao says is pre-written. No generated text.
- The user is always in control: they choose when to talk and can leave a conversation at any loop point.
- Rewards are cosmetic only. Nothing supportive is locked behind currency.
- Data stays on the device unless the user explicitly opts in to something else.

## 2. Feature specification (as built)

### 2.1 Accounts

- Sign-up and login with username and password, stored locally.
- Guest account: one tap, auto-named `guest_<timestamp>`, no password.
- Session persists across launches; logout is in the settings dialog.
- New accounts start with 3000 ✷ (the in-app currency).

### 2.2 Mood check-in and emotional weight

| Mood | Weight change | Counts as negative |
|------|---------------|--------------------|
| Happy | −3 | No |
| Okay | −2 | No |
| Sad | +1 | Yes |
| Tired | +1 | Yes |
| Anxious | +2 | Yes |

Emotional weight is clamped to 0–10. Each check-in is meant to be appended to a mood history, and a positive mood is meant to reset the consecutive-negative counter.

> **Not wired up.** The rules above exist in `InterventionManager` but nothing calls them. Choosing a mood starts a conversation without recording the check-in, so mood history stays empty and the counters stay at zero. See section 5, problem 1.

### 2.3 Conversations

- Six trees: happy (11 nodes), okay (13), sad (16), anxious (15), tired (16), intervention (8) — 79 nodes.
- A node has BaoBao's line, a list of user options, an optional feature nudge (joke, claw machine, shop, and so on), and an optional loop-point flag that ends the conversation.
- Options can carry a mood effect that adjusts emotional weight. Only eight options do, and all eight lower it.
- Text appears with a typewriter effect; each node has a matching voice clip.
- Outside conversations, quick actions give a random joke, affirmation, or self-care tip (10 each), and the home screen shows a morning, afternoon, or evening greeting.

### 2.4 Intervention

This is the intended behaviour. **It cannot currently happen**, because the inputs are never recorded (section 5, problem 1).

Triggers at the start of a conversation when **all** of these hold:

- emotional weight ≥ 4;
- at least 2 consecutive negative check-ins, **or** at least 2 of the last 3 check-ins negative;
- no intervention in the last 24 hours.

When triggered, the intervention tree replaces the mood tree. It can lead to the resources screen: Crisis Text Line (texts HELLO to 741741), 988 Suicide & Crisis Lifeline, SAMHSA helpline, NAMI helpline, and a link to mentalhealth.gov. The flag clears when a positive check-in brings the weight under the threshold.

### 2.5 Claw machine

| Rule | Value |
|------|-------|
| Free tries | 5 maximum, one refills every 5 minutes |
| Extra tries | 50 ✷ each, up to 10 purchases per day |
| Normal prize | 10–100 ✷ |
| Rare prize | 150–250 ✷, 15% chance per prize slot |
| Combo multiplier | 1.0× for 1–2 wins in a row, 1.2× for 3–4, 1.5× for 5–6, 2.0× for 7 or more; resets on a miss |
| Control | Hold to move the claw, release to drop |

Statistics kept: plays, wins, total earnings, highest single win.

### 2.6 Shop and customisation

| Item | Type | Price |
|------|------|-------|
| Kakushigoto | Music | Free (default) |
| Little | Music | 500 ✷ |
| Ordinary Days | Music | 750 ✷ |
| Default outfit | Outfit | Free (default) |
| Blue Bao | Outfit | 1000 ✷ |
| Default bamboo | Background | Free (default) |
| Bamboo Clouds | Background | 800 ✷ |
| Bamboo Plum | Background | 1000 ✷ |

Owned items are selected in the customise dialog on the home screen.

### 2.7 Settings and tutorial

- Separate volume sliders for music, effects, and voice.
- Step-through tutorial shown on first run, replayable from settings.

## 3. History — what was done

Reconstructed from git history and the removed status reports.

| Stage | Commit(s) | What happened |
|-------|-----------|---------------|
| Start | `9c0b54e` | Android Studio project created (Kotlin, with an unused C++ template). |
| Early prototype | `ce3ec38` | Bamboo-frame UI and a first, unreliable claw machine. |
| Logic build-out | `29398e3`, `78dc93f` | "Module 1–4" work: Room database and accounts, mood selection and tracking, the conversation engine and five mood trees, intervention logic and resources screen. |
| b0.1 – b0.3 | `3ac2c78` … `525755d` | Conversations moved onto the main screen; `MainActivity` split into helper classes; guest accounts; shop for music, outfit (Blue Bao), and backgrounds; settings moved into a dialog; claw machine rewritten with tries, combos, and rare prizes; crash and memory-leak fixes. |
| b0.4 – b0.4.3 | `8c8c34e` … `e5db25f` | Voice integration (142 clips), time-based greetings, tutorial, splash and loading screens, Quicksand font, status bar. |
| Cleanup | 2026-11-11 | Repository cleaned and documented; see `LOG.md`. |

The removed reports repeatedly described the app as "production ready" and "100% complete". That was not accurate; section 5 lists why.

## 4. Current state

| Area | State |
|------|-------|
| Core loop (check-in → conversation → loop) | Works |
| Voice, typewriter text, music | Works |
| Intervention and resources | **Broken** — built but never triggers (section 5, problem 1) |
| Claw machine, shop, customisation | Works, with the data-scoping bugs below |
| Tests | None |
| Continuous integration | None |
| Release configuration | None (placeholder application ID, no signing, no minification) |
| iOS | Not possible with the current codebase |

## 5. Known problems

### Safety and privacy (must fix before any release)

1. **The intervention flow is unreachable.** Mood check-ins are never recorded: nothing calls `InterventionManager.calculateNewEmotionalWeight` or `calculateConsecutiveNegativeCycles`, and nothing writes `moodHistory`. Emotional weight starts at 0 and the only code that changes it lowers it. The trigger needs weight ≥ 4, so BaoBao never suggests professional help, no matter what the user selects. The recording step was lost when mood selection moved from its own screen into a dialog. The intervention tree, its eight voice clips, and the resources screen are all present but cannot be reached in normal use.
2. **Weak password storage.** Unsalted SHA-256. Local accounts with passwords also give little real protection, because the data sits unencrypted on the device anyway.
3. **Debug account list on the login screen.** `AuthActivity.showAllAccountsDialog` shows every username and balance.
4. **Sensitive data in backups.** `allowBackup` is on with default rules, so mood history can leave the device in a backup.
5. **Helplines are United States only**, and are hard-coded. Users elsewhere get numbers that do not work for them.
6. **No disclaimer, privacy policy, or consent.** Required for a mental-health-adjacent app on both stores.
7. **Unverified music licences.** The bundled tracks' names suggest commercial music. They cannot ship without a confirmed licence.

### Correctness

8. **Destructive database migration.** Any schema change wipes all accounts and progress.
9. **Purchases are not per account.** The `purchases` table has no user ID, so one account buying an item blocks another account from buying it.
10. **Claw-machine state is not per account.** Tries, daily purchases, and statistics are device-wide.
11. **Voice clips are resolved by name at runtime.** A missing or renamed clip fails silently.
12. **Font mapping.** Every weight maps to Quicksand Bold, so regular-weight text is not available.

### Engineering

13. No tests, no CI, no crash reporting.
14. All dialogue, prices, and tutorial text are hard-coded in Kotlin or layouts; nothing is localisable.
15. Logic lives in Activities and global singletons. `ClawMachineActivity` is 1,200 lines; the claw machine uses view animation and layout-dependent hit testing.
16. `UserRepository` duplicates every method (with and without a user ID). Lists are stored as comma-separated strings and JSON-in-a-column.
17. Large uncompressed PNG character art (up to about 0.9 MB each) and about 26 MB of music inflate the APK.
18. No accessibility work: no content descriptions audit, fixed text sizes, no reduced-motion option, no captions toggle (though text always accompanies voice).
19. Android only.

## 6. Roadmap

Detail, acceptance criteria, and sequencing are in `PLAN-A-00-111126.md`.

| Phase | Outcome |
|-------|---------|
| 0. Foundations | Flutter project scaffolded beside the Kotlin app; CI, linting, and decisions on open questions. |
| 1. Content and assets | Dialogue, shop catalogue, tutorial, and helplines moved out of code into validated data files; assets optimised. |
| 2. Core domain | Mood, intervention, economy, and conversation engines as pure, fully tested Dart. |
| 3. Data layer | Typed local database with real migrations, per-profile scoping, and encrypted sensitive data. |
| 4. App shell | Navigation, theme, audio services, onboarding with disclaimer and consent. |
| 5. Features | Home and conversation, resources, shop and customisation, settings, tutorial, claw machine. |
| 6. Production hardening | Accessibility, localisation, crash reporting, performance, privacy and store compliance. |
| 7. Release | Beta on both stores, staged rollout, Kotlin app removed. |
| Later | More outfits, backgrounds, and games; mood history view; reminders; optional cloud backup. |

### Open decisions

These need an owner's answer before or during Phase 0. The plan states a recommended default for each.

1. Keep username/password accounts, or switch to local profiles with an optional device lock?
2. Which countries are in scope at launch (drives helplines and languages)?
3. Is there a licence for the current music, or should it be replaced?
4. Final application ID and store name.
5. Is any cloud feature (backup, sync) in scope for the first release?
