# PROJECT-SPECS

What BaoBao is for, what it does, what has been done, and what is left. For the code index see `CODEMAP.md`; for the plan and its status see `PLAN-A-00-111126.md`.

Last updated: 2026-11-11.

## 1. Product

**BaoBao is a pocket emotional-support companion.** A friendly panda asks how you feel, responds with a short voiced conversation suited to that mood, and offers light activities. If your check-ins stay low, BaoBao gently suggests professional support and shows helplines.

BaoBao is a comfort and self-care app. It is **not** therapy, diagnosis, or a crisis service, and it must never present itself as one.

### Objectives

1. **Emotional check-in.** Make it effortless to say how you feel and feel heard.
2. **Supportive conversation.** Respond with warm, choice-driven, voiced dialogue instead of free-text chat, so every line is authored and safe.
3. **Care escalation.** Notice sustained low mood and point to real help, without alarm and without nagging.
4. **Gentle engagement.** Give reasons to come back that are kind rather than compulsive.
5. **A consistent character.** One personality, one voice, one visual style.

### Design principles

- Every line BaoBao says is pre-written. No generated text.
- The person is always in control: they choose when to talk and can end a chat at any point.
- Rewards are cosmetic only. Nothing supportive is locked behind stars.
- Data stays on the device, encrypted. The app makes no network requests.
- Help is always one tap away in Settings, whether or not BaoBao has suggested it.

## 2. Feature specification

### 2.1 Profiles and privacy

- Local profiles with a display name. No accounts, passwords, or email.
- Several profiles can share a device; each has its own stars, items, moods, and claw-machine state.
- Optional app lock using the device's fingerprint, face, or PIN. It re-locks after 60 seconds away. Turning it on or off needs the device to confirm.
- "Delete my data" removes a profile and everything belonging to it. Deleting the last profile returns to the welcome screen.
- A new profile starts with 3000 stars, the default music, outfit, and background, and five claw-machine tries.

### 2.2 Onboarding

Welcome → disclaimer, privacy summary, and two confirmations (understands BaoBao is not professional care; is 13 or older) → name → app lock (only on devices with a screen lock). Nothing is saved until the last step. A short tour follows once.

### 2.3 Mood check-in and emotional weight

| Mood | Weight change | Counts as negative |
|------|---------------|--------------------|
| Happy | −3 | No |
| Okay | −2 | No |
| Sad | +1 | Yes |
| Tired | +1 | Yes |
| Anxious | +2 | Yes |

Weight is kept between 0 and 10. A positive check-in resets the count of consecutive negative check-ins. A conversation reply can carry a mood effect; a positive effect lowers the weight.

### 2.4 Conversations

- Six trees: happy (11 nodes), okay (13), sad (16), anxious (15), tired (16), intervention (8).
- A node has BaoBao's line, a voice clip, replies, and optionally a feature suggestion (joke, kind word, self-care idea, claw machine, shop).
- A reply leads to another node, ends the conversation, or opens the help screen.
- Text appears with a typewriter effect; a tap completes it. With reduced motion it appears at once.
- "End chat for now" is always available. BaoBao says goodbye and the place reached is saved.
- Outside conversations: a greeting by time of day (morning 05:00–11:59, afternoon 12:00–17:59, evening otherwise), and quick actions for a joke, kind word, or self-care idea (10 of each, never the same twice in a row).

### 2.5 Intervention

After recording a check-in, the intervention conversation replaces the mood's own when **all** of these hold:

- emotional weight is 4 or more;
- there have been at least 2 negative check-ins in a row, **or** at least 2 of the last 3 check-ins were negative;
- no intervention started in the last 24 hours.

Example: Anxious twice in a row triggers it on the second check-in.

### 2.6 Get help

- Shows the emergency number and helplines for the person's region, followed by worldwide directories.
- The region comes from the device and can be changed on the screen. An unknown region shows only the worldwide directories, never another country's numbers.
- Each helpline offers call, text, or website actions. If the device cannot perform one, the number or address is shown to use elsewhere.
- Currently included: United States (988, Crisis Text Line, SAMHSA, NAMI) and three international directories.

### 2.7 Claw machine

| Rule | Value |
|------|-------|
| Free tries | 5 maximum; one returns every 5 minutes |
| Extra tries | 50 stars each, up to 10 per day; can exceed the free maximum |
| Normal prize | 10–100 stars |
| Rare prize | 150–250 stars; 15% chance per prize |
| Win streak multiplier | ×1.0 for 1–2 wins in a row, ×1.2 for 3–4, ×1.5 for 5–6, ×2.0 for 7 or more; resets on a miss |
| Control | Hold to move, let go to drop. Or, as a setting, tap to start and tap to drop |

Four prizes are in the machine; it refills when empty. Plays, wins, stars won, and best win are tracked.

### 2.8 Shop and style

| Item | Type | Price |
|------|------|-------|
| Bamboo Morning | Music | Free (default) |
| Paper Lanterns | Music | 500 |
| Quiet Rain | Music | 750 |
| Classic Bao | Outfit | Free (default) |
| Blue Bao | Outfit | 1000 |
| Bamboo Grove | Background | Free (default) |
| Bamboo Clouds | Background | 800 |
| Bamboo Plum | Background | 1000 |

Buying asks for confirmation, then equips the item. Music can be previewed before buying. Owned items are switched from the "Style" sheet on home.

### 2.9 Settings

Get help; music, effects, and voice volume; voice on/off; reduce motion; tap-instead-of-hold; profile name, switching, and adding; app lock; delete my data; replay the tour; open-source licences.

## 3. History

| Stage | When | What happened |
|-------|------|---------------|
| Kotlin prototype | Up to `e5db25f` (b0.4.3) | Native Android app: accounts, mood selection, conversation trees, intervention logic, claw machine, shop, voice, tutorial. |
| Cleanup | 2026-11-11 | 71 redundant reports, crash dumps, IDE state, dead code, and unused assets removed; documentation baseline written. |
| Intervention fix | 2026-11-11 | Found that the prototype never recorded mood check-ins, so the intervention could not trigger. Fixed and tested in Kotlin. |
| Flutter rebuild | 2026-11-11 | App rebuilt in Flutter for Android and iOS (plan phases 0–5), with most of phase 6. Kotlin app removed. Music replaced with original generated tracks. Claw machine redrawn in code. |

The Kotlin source remains in git history up to commit `855d69f`.

## 4. Current state

| Area | State |
|------|-------|
| All features in section 2 | Implemented and covered by automated tests |
| Tests | 223 passing; `domain/` line coverage 95.9% |
| Android | Debug and release builds succeed. Not yet run on a device |
| iOS | Project configured. Never built |
| CI | Workflow written. Has not run on GitHub yet |
| Release | Not ready. See section 5 |

### Problems from the prototype and how they were resolved

| Prototype problem | Resolution |
|-------------------|------------|
| Intervention unreachable | Check-in and intervention decision are one tested transaction |
| Unsalted password hashes; debug account list | No passwords or accounts; optional device lock |
| Mood data in backups | Database encrypted; Android backups off |
| Database wiped on schema change | Versioned schema with snapshots; no destructive fallback |
| Purchases and claw state shared between accounts | Every table scoped to a profile; tested |
| Voice clips resolved by name at runtime | References validated both ways in CI |
| Every font weight mapped to bold | Five weights registered correctly |
| Unlicensed music | Replaced with original generated tracks |
| Hard-coded dialogue, prices, helplines | Content in validated JSON |
| Hard-coded interface text | ARB localisation files |
| Logic in Activities and singletons | Layered features with pure-Dart rules |
| No tests | 223 tests, goldens, coverage gate |
| White text on pale green buttons | Dark ink text; contrast tested to WCAG AA |
| Android only | Flutter project for Android and iOS |

## 5. What is left

### Must be done by a person before any release

1. **Run it on real devices**, Android and iOS. Nothing here has been seen running. Check audio (music ducking under voice, pausing on calls), the biometric prompt, dialling and texting, the splash screen, and performance.
2. **Verify every helpline** against its organisation's website and set `verifiedOn`. The release content check fails until this is done.
3. **Listen to the generated music and effects.** They were made by a script and checked only for length and level.
4. **Have the wording reviewed** by someone clinically qualified, especially the intervention tree and the disclaimer.
5. **Legal review** of `docs/PRIVACY.md`, then publish it at a public URL.
6. **Build and sign iOS**; create the Android upload key (`docs/RELEASE.md`).
7. **Store work:** data safety form, privacy labels, content ratings, listings, and each store's health-app policy.

### Engineering still open

8. Crash reporting (opt-in, with all personal data stripped). Not added: it needs an account and key to be chosen.
9. Screen-reader pass with TalkBack and VoiceOver. Semantics are in place and tested in code, but not by ear.
10. Performance measurement on a mid-range device.
11. Exclude the database from iCloud backup on iOS.
12. iOS `dev` and `prod` schemes (Android has both flavours).
13. Device-level integration tests. Current flow tests run the whole app in the test environment, not on a device.
14. Helplines for more countries, and a second language.

### Nice to have

15. Character art for anxious and okay moods (they reuse the sad and hello poses).
16. Richer animated backgrounds.
17. Mood history view, optional check-in reminder, a breathing exercise, more items.
