# ✅ Time-Based Greeting System Implementation

## Summary

Replaced the static "How can I help you today?" greeting with dynamic time-based greetings that change throughout the day with corresponding voice lines.

---

## Changes Made

### 1. **VoiceManager.kt** - Added Greeting Audio Support
**Location**: `app/src/main/java/com/example/baobao/audio/VoiceManager.kt`

Added new function to retrieve greeting audio files:

```kotlin
/**
 * Get audio resource ID for greeting scripts (1-3)
 * 1 = Good Morning, 2 = Good Afternoon, 3 = Good Evening
 */
fun getGreetingAudioId(context: Context, index: Int): Int {
    val name = "g_greetings_%02d".format(index.coerceIn(1, 3))
    return context.resources.getIdentifier(name, "raw", context.packageName)
}
```

---

### 2. **ConversationManager.kt** - Added Greeting Scripts
**Location**: `app/src/main/java/com/example/baobao/conversation/ConversationManager.kt`

#### Added greeting scripts array:
```kotlin
private val greetingScripts = listOf(
    "Good morning! I'm so glad you're here. Let's take today one step at a time 🌞",
    "Good afternoon. It's okay to pause sometimes. I'm here with you 🌿",
    "Good evening. Let's slow down together and take a soft breath 🌙"
)
```

#### Added time-based greeting function:
```kotlin
/**
 * Get time-based greeting with index (for audio playback)
 * @return Pair of (text, 1-based audio index)
 * 1 = Good Morning (5am-12pm)
 * 2 = Good Afternoon (12pm-6pm)
 * 3 = Good Evening (6pm-5am)
 */
fun getTimeBasedGreetingWithIndex(): Pair<String, Int> {
    val hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)
    val index = when (hour) {
        in 5..11 -> 0   // Morning: 5am-11:59am
        in 12..17 -> 1  // Afternoon: 12pm-5:59pm
        else -> 2       // Evening: 6pm-4:59am
    }
    return greetingScripts[index] to (index + 1)
}

fun getTimeBasedGreeting(): String = getTimeBasedGreetingWithIndex().first
```

---

### 3. **MainActivity.kt** - Updated to Use Time-Based Greetings
**Location**: `app/src/main/java/com/example/baobao/MainActivity.kt`

#### Updated onCreate() default greeting:
```kotlin
// Old code:
binding.conversationText.text = "How can I help you today?"

// New code:
val (greetingText, greetingIndex) = ConversationManager.getTimeBasedGreetingWithIndex()
binding.conversationText.text = greetingText
VoiceManager.playVoice(this, VoiceManager.getGreetingAudioId(this, greetingIndex))
```

#### Updated conversation end callback:
```kotlin
// Old code:
binding.conversationText.text = "I'm here whenever you need me! 🐼"

// New code:
val (greetingText, greetingIndex) = ConversationManager.getTimeBasedGreetingWithIndex()
binding.conversationText.text = greetingText
VoiceManager.playVoice(this, VoiceManager.getGreetingAudioId(this, greetingIndex))
```

---

### 4. **activity_main.xml** - Updated Default Text
**Location**: `app/src/main/res/layout/activity_main.xml`

Updated the default text in the TextView (though it's overridden at runtime):
```xml
<!-- Old: -->
android:text="How can I help you today?"

<!-- New: -->
android:text="Good morning! I'm so glad you're here. Let's take today one step at a time 🌞"
```

---

## Audio Files

The greeting audio files are already present in the `res/raw` folder:

| File | Time Period | Greeting Text |
|------|-------------|---------------|
| `g_greetings_01.aac` | 5:00 AM - 11:59 AM | "Good morning! I'm so glad you're here. Let's take today one step at a time 🌞" |
| `g_greetings_02.aac` | 12:00 PM - 5:59 PM | "Good afternoon. It's okay to pause sometimes. I'm here with you 🌿" |
| `g_greetings_03.aac` | 6:00 PM - 4:59 AM | "Good evening. Let's slow down together and take a soft breath 🌙" |

---

## Time Schedule

The greeting changes based on the device's current time:

- **Morning** (5:00 AM - 11:59 AM): Good Morning greeting
- **Afternoon** (12:00 PM - 5:59 PM): Good Afternoon greeting  
- **Evening** (6:00 PM - 4:59 AM): Good Evening greeting

---

## User Experience

### When does the user see/hear these greetings?

1. **First app launch** (when no mood is selected)
2. **After completing a conversation** (when returning to default state)
3. **When returning to MainActivity** without selecting a mood

### Voice Integration

- The greeting voice line plays automatically when the greeting is displayed
- The voice respects the user's voice volume settings
- The correct audio file is selected based on the time of day

---

## Technical Details

### Time Detection
Uses `java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)` to get the current hour (0-23).

### Audio File Naming
Follows the existing naming convention:
- Format: `g_greetings_[number].aac`
- Numbers: 01, 02, 03
- Extension: `.aac` (Advanced Audio Coding)

### Integration Points
- **VoiceManager**: Handles audio playback
- **ConversationManager**: Provides greeting text and audio index
- **MainActivity**: Displays greeting and plays audio
- **activity_main.xml**: Default TextView content

---

## Testing Checklist

✅ Greeting changes based on device time  
✅ Voice line plays with greeting  
✅ Greeting respects voice volume settings  
✅ Greeting updates after conversation ends  
✅ Audio files exist in raw folder  
✅ No compile errors  

---

## Files Modified

1. `app/src/main/java/com/example/baobao/audio/VoiceManager.kt`
2. `app/src/main/java/com/example/baobao/conversation/ConversationManager.kt`
3. `app/src/main/java/com/example/baobao/MainActivity.kt`
4. `app/src/main/res/layout/activity_main.xml`

---

## Notes

- The greeting system is fully integrated with the existing audio system
- Voice playback uses the same `VoiceManager` as other features
- The greeting respects user preferences (voice volume, voice enabled/disabled)
- The time-based logic is simple and efficient
- No additional dependencies required

