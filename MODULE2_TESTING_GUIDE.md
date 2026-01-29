# Testing Guide - MODULE 2: Conversation Engine

## Quick Start Testing

### Build & Run
```bash
cd C:\Users\Admin\AndroidStudioProjects\BaoBao
.\gradlew.bat :app:assembleDebug
.\gradlew.bat :app:installDebug
```

**Status**: ✅ BUILD SUCCESSFUL

---

## Test Scenarios

### Test 1: Happy Conversation Path 😊

**Steps:**
1. Launch app
2. Login/Signup
3. Select mood: **Happy** 😊
4. Tap "Let's Talk!"
5. **ConversationActivity** loads

**Expected Conversation Flow:**

**Exchange 1:**
```
🐼 BaoBao: That's wonderful to hear! Your happiness is contagious! 🌟 
          What's been making you smile lately?

Choices:
[Something good happened today!]
[Just feeling good overall!]
[I accomplished something!]
```

**Example Path - Choice 1:**
```
User: [Something good happened today!]

🐼: Ooh, I love good surprises! 🎉 Life has a way of sprinkling little 
    gifts when we least expect them. Want to tell me more, or should we 
    celebrate in another way?

💡 Hint: The 'Tell me a Joke' button in the main screen has more giggles!

Choices:
[Let's celebrate! Tell me a joke!]
[I want to savor this feeling]
```

**Example Path - Choice 2:**
```
User: [Let's celebrate! Tell me a joke!]

🐼: Why did the panda like the bamboo restaurant? Because it had great 
    stalks! 🎋😄 Okay okay, I know, my jokes are panda-monium! Want to 
    keep the good vibes rolling?

Choices:
[Yes! What else can we do?]
[I'm good for now, thank you!]
```

**Loop Point:**
```
🐼: You've brought such good energy today! I'm so glad we got to share 
    this happy moment together. 💚 How's your heart feeling now?

Choices:
[Check in with my mood]
```

**Result:** Returns to MoodSelectionActivity

---

### Test 2: Sad Conversation Path 😢

**Steps:**
1. Launch app
2. Login/Signup
3. Select mood: **Sad** 😢
4. Tap "Let's Talk!"

**Expected Conversation Flow:**

**Exchange 1:**
```
🐼 BaoBao: I'm here with you, friend. 💙 Sadness is heavy, but you don't 
          have to carry it alone. Want to talk about what's weighing on 
          you, or would you prefer some gentle company?

Choices:
[I want to talk about it]
[Just want to feel less alone]
[I don't know what I need]
```

**Example Path - Seeking Company:**
```
User: [Just want to feel less alone]

🐼: You're not alone. I'm right here, and I'm not going anywhere. 🐼 
    Sometimes we don't need words—just knowing someone cares is enough. 
    Want to sit together quietly, or would a small distraction help?

Choices:
[Just sit with me]
[A gentle distraction might help]
```

**Deeper Path:**
```
User: [Just sit with me]

🐼: *sits quietly beside you* 🐼💙 You're doing great just by being here. 
    Take all the time you need. I'm here whenever you're ready.

Choices:
[*takes a deep breath*]
[This helps, thank you]
```

**Comforting Response:**
```
User: [*takes a deep breath*]

🐼: That's it. Breathing is healing. You're here, you're present, and 
    that takes strength. I'm proud of you for taking this moment for 
    yourself. 🌬️💙

Choices:
[I feel a little calmer]
[Still struggling]
```

**Loop Point:**
```
🐼: You've been so brave today, sharing these feelings with me. Remember, 
    it's okay to not be okay. I'm here whenever you need me. 💙 
    How's your heart feeling now?

Choices:
[Check in with my mood]
```

**Result:** Returns to MoodSelectionActivity

---

## UI Verification Checklist

### Visual Elements
- [ ] BaoBao character visible (200dp x 200dp)
- [ ] Character animates slightly when dialogue changes
- [ ] Dialogue box has green border (3dp stroke)
- [ ] Speaker name shows: "🐼 BaoBao"
- [ ] Decorative divider line present
- [ ] Dialogue text readable (17sp, proper spacing)

### Choice Buttons
- [ ] All choices displayed as buttons
- [ ] Buttons color-coded by mood:
  - Happy: Light Yellow background, Gold stroke
  - Sad: Light Blue background, Blue stroke
- [ ] Buttons have rounded corners (16dp)
- [ ] Buttons have proper padding
- [ ] Click sound plays on tap

### Feature Nudges
- [ ] Nudge appears when appropriate
- [ ] Nudge has light green background
- [ ] Text is italic and green
- [ ] Nudge hides when not needed
- [ ] Examples:
  - "💡 Hint: The claw machine game is waiting for you..."
  - "💡 Hint: Check out the 'Self-Care' button..."

---

## Conversation Flow Tests

### Test 3: Complete Happy Journey
```
happy_start
  → [Something good happened!]
happy_good_thing
  → [Let's celebrate! Tell me a joke!]
happy_celebrate_joke
  → [Yes! What else can we do?]
happy_whats_next
  → [Sounds perfect!]
happy_loop
  → [Check in with my mood]
→ Return to MoodSelectionActivity
```

**Expected:** 4 exchanges, returns smoothly

### Test 4: Complete Sad Journey
```
sad_start
  → [Just want to feel less alone]
sad_company
  → [Just sit with me]
sad_sit_together
  → [*takes a deep breath*]
sad_deep_breath
  → [I feel a little calmer]
sad_loop
  → [Check in with my mood]
→ Return to MoodSelectionActivity
```

**Expected:** 5 exchanges, returns smoothly

---

## Edge Case Testing

### Test 5: Back Button Handling
1. Start any conversation
2. Make 2-3 choice selections
3. Press Android back button
4. **Expected:** Smooth return to MoodSelectionActivity
5. **Expected:** No crashes or errors

### Test 6: Rapid Clicking
1. Start conversation
2. Quickly tap choice button multiple times
3. **Expected:** Only one navigation occurs
4. **Expected:** No duplicate screens

### Test 7: Screen Rotation (if enabled)
1. Start conversation mid-flow
2. Rotate device
3. **Expected:** Dialogue preserved
4. **Expected:** Choices still functional

---

## Database Verification

### Test 8: Conversation Path Tracking
1. Start any conversation
2. Make 3 choice selections
3. Open Database Inspector (Android Studio)
4. Check `user_data` table:
   - `currentConversationPath` should contain JSON array
   - `lastConversationNodeId` should have last node ID

**Example Data:**
```json
currentConversationPath: 
["happy_start","happy_good_thing","happy_celebrate_joke","happy_whats_next"]

lastConversationNodeId: "happy_whats_next"
```

### Test 9: Emotional Weight Tracking
1. Select **Sad** mood (weight +1)
2. During conversation, watch for mood effect choices
3. Check database after conversation
4. **Expected:** `emotionalWeight` updated appropriately

---

## BaoBao Personality Verification

### Test 10: Validation Check ✅
Review sad mood responses - ALL should include:
- [ ] "I'm here with you"
- [ ] "Your feelings are valid"
- [ ] "It's okay to feel..."
- [ ] Never: "You should..." or "You must..."

### Test 11: Choice Offering ✅
Review all nodes - ALL should:
- [ ] Offer 2-3 choices
- [ ] Never demand specific action
- [ ] Allow user agency
- [ ] Example: "Want to..." not "You need to..."

### Test 12: Warmth Check ✅
Review happy mood responses:
- [ ] Uses celebratory language ("wonderful!", "look at you go!")
- [ ] Includes emoji appropriately
- [ ] Playful panda references ("panda-monium")
- [ ] Encouraging without being patronizing

---

## Feature Nudge Testing

### Test 13: Joke Nudge
1. Happy mood → Choice: "Something good happened!"
2. **Expected Nudge:** 
   ```
   💡 Hint: The 'Tell me a Joke' button in the main screen has more giggles!
   ```
3. Verify nudge appears but isn't intrusive

### Test 14: Claw Machine Nudge
1. Happy mood → Path to "fun activity"
2. **Expected Nudge:**
   ```
   💡 Hint: The claw machine game is waiting for you on the main screen!
   ```

### Test 15: Self-Care Nudge
1. Sad mood → Choose distraction path
2. **Expected Nudge:**
   ```
   💡 Hint: Check out the 'Self-Care' button for more gentle suggestions!
   ```

### Test 16: Shop Nudge
1. Happy mood → Path to "what's next"
2. **Expected Nudge:**
   ```
   💡 Hint: The shop has some lovely customizations to explore!
   ```

---

## Performance Testing

### Test 17: Loading Speed
1. Select mood and tap "Let's Talk!"
2. **Expected:** ConversationActivity loads within 1 second
3. **Expected:** No lag or stuttering

### Test 18: Animation Smoothness
1. Watch character animation on dialogue change
2. **Expected:** Smooth scale animation (200ms)
3. **Expected:** No jankiness

### Test 19: Memory Usage
1. Complete 3-4 full conversations
2. Check memory usage in Android Profiler
3. **Expected:** No memory leaks
4. **Expected:** Consistent memory footprint

---

## Integration Testing

### Test 20: Full User Journey
```
1. Launch App
   ↓
2. AuthActivity → Login
   ↓
3. LoadingActivity (1.5s)
   ↓
4. MoodSelectionActivity → Select "Happy"
   ↓
5. ConversationActivity
   ↓
6. Complete 4 exchanges
   ↓
7. Reach loop point
   ↓
8. Return to MoodSelectionActivity
   ↓
9. Select different mood "Sad"
   ↓
10. New conversation starts
    ↓
11. Complete 5 exchanges
    ↓
12. Return to MoodSelectionActivity
```

**Expected:** Seamless flow, no crashes, all data saved

---

## Success Criteria

| Feature | Test | Status |
|---------|------|--------|
| Happy conversation loads | Test 1 | ⬜ |
| Sad conversation loads | Test 2 | ⬜ |
| 3-5 exchanges work | Tests 3-4 | ⬜ |
| Loop returns to mood selector | All tests | ⬜ |
| Back button handled | Test 5 | ⬜ |
| UI matches design | Visual checklist | ⬜ |
| Choices color-coded | Visual checklist | ⬜ |
| Feature nudges appear | Tests 13-16 | ⬜ |
| BaoBao personality consistent | Tests 10-12 | ⬜ |
| Database tracking works | Tests 8-9 | ⬜ |
| No crashes | All tests | ⬜ |
| Performance good | Tests 17-19 | ⬜ |

---

## Known Limitations

### Current Scope (Module 2)
- ✅ Happy and Sad moods only
- ⏳ Anxious, Tired, Okay moods (Module 3)
- ✅ Basic feature nudging
- ⏳ Advanced intervention logic (Module 3)
- ✅ Conversation path tracking
- ⏳ Conversation analytics (Module 3)

---

## Troubleshooting

### Issue: Conversation doesn't start
**Solution:**
- Check mood was passed in intent
- Verify ConversationActivity registered in manifest
- Check ConversationScripts has starting node

### Issue: Choices not appearing
**Solution:**
- Verify node has userOptions defined
- Check layout file for choicesContainer
- Rebuild project

### Issue: Loop doesn't return to mood selector
**Solution:**
- Check node's isLoopPoint = true
- Verify "return_to_mood" nextNodeId
- Check MoodSelectionActivity in manifest

### Issue: Feature nudges not showing
**Solution:**
- Verify featureNudge field in node
- Check showFeatureNudge() logic
- Ensure featureNudgeText view exists

---

## Next Steps After Testing

Once Module 2 testing is complete:

1. **Document Issues**: Note any bugs or UX concerns
2. **User Feedback**: Get feedback on conversation flow
3. **Personality Check**: Ensure BaoBao voice is consistent
4. **Prepare Module 3**: 
   - Add Anxious, Tired, Okay mood scripts
   - Implement intervention thresholds
   - Create resource screen
   - Add advanced analytics

---

**Testing Date**: January 28, 2026  
**Module**: 2 - Conversation Engine  
**Status**: ✅ READY FOR TESTING  
**Build**: SUCCESSFUL
