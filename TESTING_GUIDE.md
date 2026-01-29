# Quick Start Guide - MODULE 1 Testing

## Build & Run

### 1. Build the App
```bash
cd C:\Users\Admin\AndroidStudioProjects\BaoBao
.\gradlew.bat :app:assembleDebug
```

**Status**: ✅ BUILD SUCCESSFUL

### 2. Install on Device/Emulator
```bash
.\gradlew.bat :app:installDebug
```

OR manually install the APK from:
```
app/build/outputs/apk/debug/app-debug.apk
```

## Testing Flow

### Test 1: First-Time User Flow
1. Launch app → **AuthActivity** appears
2. Tap "Don't have an account? Sign Up"
3. See BaoBao's signup message (random from #1-5)
4. Enter any email/password (validation not implemented yet)
5. Tap "Sign Up" button
6. **LoadingActivity** shows (1.5 seconds)
7. **MoodSelectionActivity** appears with:
   - BaoBao character
   - "How are you feeling right now?"
   - 5 colorful mood cards

8. Tap any mood card (e.g., "Sad 😢")
9. See response: "I'm here with you, friend. It's okay to feel down sometimes. Let's talk about it together. 💙"
10. "Let's Talk!" button enables
11. Tap "Let's Talk!"
12. **MainActivity** appears with personalized greeting
13. See: "I'm here for you, friend. It's okay to feel this way. Would you like some comfort, a distraction, or just someone to be with? 💙"

### Test 2: Returning User Flow
1. Launch app → **AuthActivity** appears
2. See "Login" button (default view)
3. See BaoBao's login message (random from #6-10)
4. Tap "Login"
5. **LoadingActivity** shows (1.5 seconds)
6. **MoodSelectionActivity** appears (same as above)
7. Select different mood (e.g., "Happy 😊")
8. See response: "That's wonderful! I love hearing that! Let's keep those good vibes going! ✨"
9. Tap "Let's Talk!"
10. **MainActivity** shows happy greeting

### Test 3: Mood Check-In (From Main Screen)
1. From **MainActivity**, tap on **BaoBao character** (center image)
2. Hear click sound
3. Navigate back to **MoodSelectionActivity**
4. Select new mood
5. Return to **MainActivity** with updated greeting

### Test 4: Mood History (Database Persistence)
1. Select mood "Anxious" → Check database
2. Close app completely
3. Reopen app → Login → Select mood "Happy"
4. Check database to verify:
   - `moodHistory` contains 2 entries (JSON array)
   - `currentMood` = "happy"
   - `emotionalWeight` = 2 (Anxious=2, Happy=0)
   - `consecutiveNegativeCycles` = 0 (reset on positive mood)

## Database Inspection

### Using Android Studio Database Inspector:
1. Run app on emulator/device
2. View → Tool Windows → App Inspection
3. Select "baobao_database"
4. Open table "user_data"
5. Verify columns:
   - userId = 1
   - currency = 1000
   - currentMood = (last selected)
   - moodHistory = (JSON array)
   - emotionalWeight = (cumulative)
   - consecutiveNegativeCycles
   - interventionTriggered = false

### Sample moodHistory JSON:
```json
[
  {"mood":"anxious","timestamp":1738051200000,"weight":2},
  {"mood":"happy","timestamp":1738054800000,"weight":0}
]
```

## Expected Behaviors

### Mood Card Selection:
- ✅ Cards change appearance on selection:
  - Stroke width: 4dp → 8dp
  - Elevation: 6dp → 12dp
- ✅ Only one card selected at a time
- ✅ Click sound plays on each tap
- ✅ Response text updates based on selection
- ✅ "Let's Talk!" button disabled until selection

### Mood Responses:
- **Happy**: "That's wonderful! I love hearing that! Let's keep those good vibes going! ✨"
- **Okay**: "I hear you. Some days are just... okay. And that's perfectly fine! Let's see if we can brighten it up a bit! 🌤️"
- **Sad**: "I'm here with you, friend. It's okay to feel down sometimes. Let's talk about it together. 💙"
- **Anxious**: "I understand. Those worried feelings can be tough. Take a deep breath with me—I've got you. 🫂"
- **Tired**: "You've been working hard, haven't you? Let's find some gentle ways to help you recharge. 🌙"

### MainActivity Greetings (After Mood Selection):
- **Happy**: "I'm so happy you're feeling good! What would you like to do today? Maybe hear a joke or just hang out? 😊"
- **Okay**: "Thanks for sharing how you're feeling. I'm here with you! Want to chat, play a game, or just take it easy? 🐼"
- **Sad**: "I'm here for you, friend. It's okay to feel this way. Would you like some comfort, a distraction, or just someone to be with? 💙"
- **Anxious**: "I can sense those worried feelings. Let's take this moment by moment together. Want to try something calming, or talk it out? 🫂"
- **Tired**: "You've been working so hard. Let's find a gentle way to help you feel better. Maybe something relaxing? 🌙"

## Features Working

### From MainActivity:
- ✅ Settings button → Settings dialog
- ✅ Shop button → Shop activity
- ✅ Claw Machine button → Claw machine game
- ✅ Customize button → Theme/BGM customization
- ✅ Character tap → Mood check-in
- ✅ Action buttons (Joke, Affirmation, Self-Care, Goodbye)

## Troubleshooting

### Build Issues:
- If IDE shows errors but Gradle builds successfully, try:
  - File → Invalidate Caches → Invalidate and Restart
  - Build → Clean Project
  - Build → Rebuild Project

### Database Issues:
- Clear app data to reset database:
  - Settings → Apps → BaoBao → Storage → Clear Data
- Or uninstall and reinstall app

### View Binding Issues:
- Ensure `buildFeatures { viewBinding = true }` in app/build.gradle.kts
- Clean and rebuild project

## Next Steps (Module 2)

Once testing is complete, Module 2 will add:
- Branching conversation trees based on mood
- Visual novel-style dialogue system
- Emotional weight thresholds
- Professional intervention suggestions
- Feature nudging (organic suggestions for claw machine, etc.)

---

**Current Status**: ✅ MODULE 1 COMPLETE & READY FOR TESTING
**Build**: ✅ SUCCESSFUL
**Database**: ✅ Version 2 with mood tracking
**UI**: ✅ Mood selection fully functional
