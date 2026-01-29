# 🔴 BaoBao Logic Inconsistency Report

**Analysis Date**: January 28, 2026  
**Severity Levels**: 🔴 Critical | 🟠 Major | 🟡 Minor | 🔵 Info

---

## 🔴 CRITICAL ISSUES

### 1. Currency Stored in TWO Different Locations (Data Desync)

**Problem**: Currency is stored in both **SharedPreferences** AND **Room Database**, causing potential data conflicts.

**Location 1 - SharedPreferences** (MainActivity.kt):
```kotlin
// Line 160
val currency = prefs.getInt("currency", 1250)  // Default: 1250

// Lines 195, 221
prefs.edit().putInt("currency", newCurrency).apply()
```

**Location 2 - Room Database** (UserData.kt):
```kotlin
// Line 9
val currency: Int = 1000  // Default: 1000
```

**Claw Machine adds to Database**:
```kotlin
// ClawMachineActivity.kt Line 461
userRepository.addCurrency(amount)  // Uses Room DB
```

**Customize Dialog reads/writes SharedPreferences**:
```kotlin
// MainActivity.kt Line 160
prefs.getInt("currency", 1250)  // Different default too!
```

**Impact**: 
- User earns currency in Claw Machine → Saved to DB
- User tries to buy BGM in Customize dialog → Reads from SharedPreferences (different value)
- Currency gets out of sync between the two storage locations

**Fix Required**: Use ONLY one storage mechanism (Room DB) for currency.

---

### 2. Emotional Weight Never Decreases (Except Minor Reset)

**Problem**: Emotional weight only decreases by 1 when user selects a positive mood, but it ALWAYS increases on negative moods. This means the weight accumulates indefinitely over time.

**Increment Logic** (MoodSelectionActivity.kt Lines 150-151):
```kotlin
val newEmotionalWeight = userData.emotionalWeight + mood.weight
// Sad = +1, Anxious = +2, Tired = +1
```

**Decrement Logic** (InterventionManager.kt Lines 83-86):
```kotlin
val reducedWeight = maxOf(0, userData.emotionalWeight - 1)  // Only -1!
```

**Scenario**:
- User selects Anxious 3 times: Weight = 6
- User selects Happy once: Weight = 5 (only -1)
- User is stuck at high weight

**Impact**: Once a user hits intervention threshold (4), they'll keep triggering it frequently even after improvement.

**Fix Required**: More aggressive weight reduction on positive moods or natural decay over time.

---

### 3. Intervention Never Resets Properly

**Problem**: `interventionTriggered` only resets when user selects positive mood AND already has triggered=true. But the reset also doesn't decrease consecutive negative cycles.

**Current Logic** (InterventionManager.kt Lines 77-90):
```kotlin
return if (currentMood in positiveMoods && userData.interventionTriggered) {
    // Reset flag
} else {
    userData  // No change if not triggered yet
}
```

**Issue**: If user has high emotionalWeight (say 5) but intervention hasn't triggered yet, selecting Happy:
- Doesn't reduce emotionalWeight (intervention wasn't triggered)
- Weight stays at 5
- Next negative mood triggers intervention immediately

**Impact**: Intervention can be triggered immediately after positive moods if weight was already high.

---

## 🟠 MAJOR ISSUES

### 4. Default Buttons Still Visible During Conversation (Potential)

**Problem**: When `setupActionButtons()` is called, it sets click listeners on buttons that should be hidden during conversation mode. If visibility switching fails, users could click them.

**Code** (MainActivity.kt Lines 124-142):
```kotlin
private fun setupActionButtons() {
    binding.jokeButton.setOnClickListener {
        // No check for isConversationMode!
        binding.conversationText.text = ConversationManager.getRandomJoke()
    }
    // Same for other buttons...
}
```

**Impact**: If `defaultButtonsContainer.visibility = View.GONE` fails, buttons would still respond to clicks and interfere with conversation.

**Fix Required**: Add `isConversationMode` check in button click handlers.

---

### 5. BGM Ownership Stored in TWO Locations

**Problem**: Similar to currency, BGM ownership is stored in both SharedPreferences (owned_bgms) and Room DB (purchasedBgm).

**SharedPreferences** (MainActivity.kt Line 161):
```kotlin
val ownedBGMs = prefs.getStringSet("owned_bgms", setOf("kakushigoto"))
```

**Room DB** (UserData.kt Line 10):
```kotlin
val purchasedBgm: String = ""  // Comma-separated list
```

**Impact**: BGM purchased through shop could use DB, but customize dialog uses SharedPreferences.

---

### 6. applyMoodEffect Does Nothing

**Problem**: The `applyMoodEffect` function is called but has no implementation.

**Code** (MainActivity.kt Lines 563-567):
```kotlin
private fun applyMoodEffect(effect: Int) {
    // TODO: Visual feedback for mood improvement
    if (effect > 0) {
        // Positive effect - maybe show sparkles or happy animation
    }
}
```

**Where it's called** (Line 542):
```kotlin
if (moodEffect != 0) {
    applyMoodEffect(moodEffect)  // Does nothing!
}
```

**Impact**: Conversation nodes with `moodEffect` values have no actual effect on user state.

---

### 7. Conversation Nodes with moodEffect Don't Update UserData

**Problem**: When user makes a choice with `moodEffect`, it should update `emotionalWeight` in the database, but it doesn't.

**Expected**: Positive moodEffect should reduce emotionalWeight
**Actual**: `applyMoodEffect()` is empty, no database update

**Impact**: Therapeutic conversation choices have no lasting effect on intervention logic.

---

## 🟡 MINOR ISSUES

### 8. updateStatus Shows Hardcoded Mood, Not User's Actual Mood

**Problem**: Status card shows time-based mood, not the user's selected mood.

**Code** (MainActivity.kt Lines 595-607):
```kotlin
val (emoji, mood) = when (hour) {
    in 5..11 -> "🌅" to "Energized"
    in 12..17 -> "😊" to "Happy"
    // ...
}
binding.moodText.text = "$emoji $mood"
```

**Issue**: After user selects "Sad", the status card might show "😊 Happy" based on time.

**Impact**: Confusing UX - status doesn't reflect user's emotional state.

---

### 9. Different Default Currency Values

**Problem**: Multiple default values for currency across the codebase.

| Location | Default Value |
|----------|---------------|
| UserData.kt | 1000 |
| MainActivity.kt (SharedPreferences) | 1250 |
| UserRepository.kt getCurrency() | 1000 |

**Impact**: New users could see different currency depending on which screen loads first.

---

### 10. ResourcesActivity Not Extending BaseActivity

**Problem**: ResourcesActivity extends `AppCompatActivity` instead of `BaseActivity`, so no BGM plays on resources screen.

**Code** (ResourcesActivity.kt Line 9):
```kotlin
class ResourcesActivity : AppCompatActivity() {  // Not BaseActivity!
```

**Impact**: Music stops when viewing professional help resources (might be intentional for serious screen, but inconsistent).

---

### 11. SFX Volume Setting Not Applied

**Problem**: SFX volume is saved to SharedPreferences but the slider listener has a TODO comment.

**Code** (MainActivity.kt Lines 332-336):
```kotlin
dialogBinding.sfxSlider.addOnChangeListener { _, value, _ ->
    val volume = value / 100f
    prefs.edit().putFloat("sfx_volume", volume).apply()
    // TODO: Apply to SoundManager when SFX system is implemented
}
```

**Actual SoundManager.playClickSound()** (Line 54-66):
```kotlin
fun playClickSound(context: Context) {
    val prefs = context.getSharedPreferences("BaoBaoPrefs", Context.MODE_PRIVATE)
    val sfxVolume = prefs.getFloat("sfx_volume", 0.8f)
    // Actually DOES apply volume...
}
```

**Impact**: Comment is outdated - SFX volume IS applied. No bug, just misleading comment.

---

### 12. Tries Timer Continues When Activity is Paused

**Problem**: `timerUpdateRunnable` is not stopped in `onPause()`, only data is saved.

**Code** (ClawMachineActivity.kt Lines 476-479):
```kotlin
override fun onPause() {
    super.onPause()
    saveTriesData()
    // Missing: handler.removeCallbacks(timerUpdateRunnable)
}
```

**Impact**: Timer might continue updating UI in background, though it gets cleaned in `onDestroy()`.

---

## 🔵 INFO / RECOMMENDATIONS

### 13. Conversation Path Not Persisted

**Problem**: `currentConversationPath` and `lastConversationNodeId` exist in UserData but aren't used.

**UserData fields** (Lines 23-24):
```kotlin
val currentConversationPath: String = "",
val lastConversationNodeId: String = ""
```

**saveConversationState()** only saves mood:
```kotlin
val updatedData = userData.copy(
    currentMood = currentMood ?: "okay"
    // Missing: currentConversationPath, lastConversationNodeId
)
```

**Impact**: Can't resume conversation after app restart.

---

### 14. Voice Volume Setting Has No Effect

**Problem**: Voice volume is saved but never used (no voice system yet).

**Code** (MainActivity.kt Lines 338-342):
```kotlin
dialogBinding.voiceSlider.addOnChangeListener { _, value, _ ->
    // TODO: Apply to voice system when implemented
}
```

**Impact**: Setting exists but does nothing until audio implemented.

---

## 📋 PRIORITY FIX ORDER

| Priority | Issue | Severity | Effort |
|----------|-------|----------|--------|
| 1 | Currency dual storage | 🔴 Critical | Medium |
| 2 | Emotional weight doesn't decay | 🔴 Critical | Low |
| 3 | Intervention reset logic | 🔴 Critical | Medium |
| 4 | BGM ownership dual storage | 🟠 Major | Medium |
| 5 | applyMoodEffect empty | 🟠 Major | Low |
| 6 | moodEffect not updating DB | 🟠 Major | Medium |
| 7 | Add conversation mode check | 🟠 Major | Low |
| 8 | Status shows wrong mood | 🟡 Minor | Low |
| 9 | Default currency mismatch | 🟡 Minor | Low |
| 10 | Timer cleanup in onPause | 🟡 Minor | Low |

---

## 🔧 RECOMMENDED FIXES

### Fix #1: Consolidate Currency to Database Only

```kotlin
// In showCustomizeDialog(), replace:
val currency = prefs.getInt("currency", 1250)

// With:
lifecycleScope.launch {
    val currency = userRepository.getCurrency()
    // ... rest of logic
}
```

### Fix #2: Better Emotional Weight Decay

```kotlin
// In InterventionManager.resetInterventionIfImproved():
val reducedWeight = if (currentMood == "happy") {
    maxOf(0, userData.emotionalWeight - 3)  // Happy = -3
} else if (currentMood == "okay") {
    maxOf(0, userData.emotionalWeight - 2)  // Okay = -2
} else {
    userData.emotionalWeight
}
```

### Fix #3: Implement applyMoodEffect

```kotlin
private fun applyMoodEffect(effect: Int) {
    lifecycleScope.launch {
        val userData = userRepository.getUserData()
        val newWeight = maxOf(0, userData.emotionalWeight - effect)
        val updated = userData.copy(emotionalWeight = newWeight)
        userRepository.updateUserData(updated)
    }
}
```

---

## 📊 SUMMARY

| Severity | Count |
|----------|-------|
| 🔴 Critical | 3 |
| 🟠 Major | 4 |
| 🟡 Minor | 5 |
| 🔵 Info | 2 |
| **Total** | **14** |

**Most Critical**: Currency stored in two locations will cause bugs where users earn currency but can't spend it (or vice versa).

**Action Required**: Address Critical issues before production release.

---

**Report Generated**: January 28, 2026  
**Analyzed Files**: 15  
**Build Status**: ✅ Compiles (but has logic bugs)
