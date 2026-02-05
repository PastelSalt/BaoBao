# Character Image Manager - Outfit & Emotion System

## Summary
Created a comprehensive system to manage BaoBao character images based on outfit and emotion states. The system is designed to support multiple outfits with different emotional expressions.

## Implementation

### 1. CharacterImageManager.kt
**Location**: `app/src/main/java/com/example/baobao/CharacterImageManager.kt`

**Purpose**: Centralized manager for character images that supports:
- Multiple outfits (outfit1, outfit2, etc.)
- Multiple emotions per outfit (happy, hello, sad, tired, anxious, okay)
- Easy switching between outfits
- Fallback handling for missing images

### 2. Available Images (Outfit 1)
Current images in drawable folder:
- ✅ `mainscreen_outfit1_fullbody_happy.png`
- ✅ `mainscreen_outfit1_fullbody_hello.png`
- ✅ `mainscreen_outfit1_fullbody_sad.png`
- ✅ `mainscreen_outfit1_fullbody_tired.png`

### 3. Naming Convention
**Pattern**: `mainscreen_outfit{NUMBER}_fullbody_{EMOTION}.png`

Examples:
- `mainscreen_outfit1_fullbody_happy.png`
- `mainscreen_outfit1_fullbody_sad.png`
- `mainscreen_outfit2_fullbody_happy.png` (future)
- `mainscreen_outfit2_fullbody_tired.png` (future)

## Usage

### Setting Character Image by Emotion
```kotlin
// Using emotion enum
binding.characterImage.setImageResource(
    CharacterImageManager.getCharacterImage(CharacterImageManager.Emotion.HAPPY)
)

// Using mood string (happy, sad, tired, anxious, okay)
binding.characterImage.setImageResource(
    CharacterImageManager.getCharacterImageForMood("happy")
)

// Get hello/greeting image
binding.characterImage.setImageResource(
    CharacterImageManager.getHelloImage()
)
```

### Switching Outfits
```kotlin
// Set current outfit (affects all subsequent image requests)
CharacterImageManager.setOutfit("outfit1")

// Get current outfit name
val currentOutfit = CharacterImageManager.getCurrentOutfit()

// Get image with specific outfit override
val image = CharacterImageManager.getCharacterImage(
    CharacterImageManager.Emotion.HAPPY,
    outfit = "outfit2"
)
```

### Checking Availability
```kotlin
// Check if outfit exists
if (CharacterImageManager.isOutfitAvailable("outfit2")) {
    // Use outfit2
}

// Get list of all available outfits
val outfits = CharacterImageManager.getAvailableOutfits()

// Get available emotions for current outfit
val emotions = CharacterImageManager.getAvailableEmotions()
```

## MainActivity Integration

### Changes Made:

1. **Initialization** (onCreate):
```kotlin
// Set initial character image to hello/greeting
binding.characterImage.setImageResource(CharacterImageManager.getHelloImage())
```

2. **Mood Selection** (showMoodGreeting):
```kotlin
// Update character image to match mood
binding.characterImage.setImageResource(
    CharacterImageManager.getCharacterImageForMood(mood)
)
```

3. **Conversation Start** (startConversation):
```kotlin
// Update character image to match mood
binding.characterImage.setImageResource(
    CharacterImageManager.getCharacterImageForMood(mood)
)
```

### Layout Update

**File**: `activity_main.xml`

Updated default character image:
```xml
<!-- Before -->
android:src="@drawable/baobao_main_default"

<!-- After -->
android:src="@drawable/mainscreen_outfit1_fullbody_hello"
```

## Adding New Outfits

### Step 1: Add Images
Add new images to `app/src/main/res/drawable/`:
```
mainscreen_outfit2_fullbody_happy.png
mainscreen_outfit2_fullbody_hello.png
mainscreen_outfit2_fullbody_sad.png
mainscreen_outfit2_fullbody_tired.png
mainscreen_outfit2_fullbody_anxious.png (optional)
mainscreen_outfit2_fullbody_okay.png (optional)
```

### Step 2: Update CharacterImageManager.kt

Add outfit2 handler:
```kotlin
private fun getOutfit2Image(emotion: Emotion): Int {
    return when (emotion) {
        Emotion.HAPPY -> R.drawable.mainscreen_outfit2_fullbody_happy
        Emotion.HELLO -> R.drawable.mainscreen_outfit2_fullbody_hello
        Emotion.SAD -> R.drawable.mainscreen_outfit2_fullbody_sad
        Emotion.TIRED -> R.drawable.mainscreen_outfit2_fullbody_tired
        Emotion.ANXIOUS -> R.drawable.mainscreen_outfit2_fullbody_anxious
        Emotion.OKAY -> R.drawable.mainscreen_outfit2_fullbody_okay
        Emotion.DEFAULT -> R.drawable.mainscreen_outfit2_fullbody_hello
    }
}
```

Update the main getCharacterImage function:
```kotlin
fun getCharacterImage(emotion: Emotion, outfit: String? = null): Int {
    val selectedOutfit = outfit ?: currentOutfit
    
    return when (selectedOutfit) {
        "outfit1" -> getOutfit1Image(emotion)
        "outfit2" -> getOutfit2Image(emotion)  // Add this line
        // Add more outfits here as they become available
        else -> getOutfit1Image(emotion)
    }
}
```

Update available outfits:
```kotlin
fun getAvailableOutfits(): List<String> {
    return listOf("outfit1", "outfit2")  // Add outfit2
}

fun isOutfitAvailable(outfitName: String): Boolean {
    return outfitName in listOf("outfit1", "outfit2")  // Add outfit2
}
```

### Step 3: Allow User Selection (Future Feature)
```kotlin
// In settings or customization screen
CharacterImageManager.setOutfit("outfit2")

// Save to preferences
val prefs = getSharedPreferences("settings", Context.MODE_PRIVATE)
prefs.edit().putString("selected_outfit", "outfit2").apply()

// Load on app start
val savedOutfit = prefs.getString("selected_outfit", "outfit1") ?: "outfit1"
CharacterImageManager.setOutfit(savedOutfit)
```

## Emotion Mapping

| Mood String | Emotion Enum | Outfit1 Image |
|-------------|--------------|---------------|
| "happy" | HAPPY | mainscreen_outfit1_fullbody_happy |
| "sad" | SAD | mainscreen_outfit1_fullbody_sad |
| "tired" | TIRED | mainscreen_outfit1_fullbody_tired |
| "anxious" | ANXIOUS | mainscreen_outfit1_fullbody_sad (fallback) |
| "okay" | OKAY | mainscreen_outfit1_fullbody_hello (fallback) |
| "hello", "greeting" | HELLO | mainscreen_outfit1_fullbody_hello |
| default | DEFAULT | mainscreen_outfit1_fullbody_hello |

## Fallback Strategy

1. If specific emotion image doesn't exist, uses closest emotion
2. If outfit doesn't exist, falls back to outfit1
3. If all else fails, uses HELLO/DEFAULT image

## Future Enhancements

### 1. Add Missing Emotions
Create these images for complete emotion coverage:
- `mainscreen_outfit1_fullbody_anxious.png`
- `mainscreen_outfit1_fullbody_okay.png`

### 2. Add Animation Support
```kotlin
// Smooth transition between images
fun animateCharacterImageChange(
    imageView: ImageView,
    newEmotion: Emotion,
    duration: Long = 300
) {
    imageView.animate()
        .alpha(0.7f)
        .setDuration(duration / 2)
        .withEndAction {
            imageView.setImageResource(getCharacterImage(newEmotion))
            imageView.animate()
                .alpha(1f)
                .setDuration(duration / 2)
                .start()
        }
        .start()
}
```

### 3. Outfit Customization Shop
- Allow users to purchase/unlock new outfits
- Store unlocked outfits in database
- Add outfit preview in customization dialog

### 4. Context-Based Emotions
```kotlin
// Time-based emotions
fun getTimeBasedEmotion(): Emotion {
    val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    return when (hour) {
        in 6..11 -> Emotion.HELLO  // Morning
        in 12..17 -> Emotion.HAPPY  // Afternoon
        in 18..21 -> Emotion.OKAY   // Evening
        else -> Emotion.TIRED        // Night
    }
}
```

## Benefits

1. **Scalability**: Easy to add new outfits and emotions
2. **Maintainability**: Centralized image management
3. **Flexibility**: Can override outfit on per-call basis
4. **Type Safety**: Using enums prevents string typos
5. **User Personalization**: Foundation for outfit selection feature

## Testing Checklist

- [ ] Character shows hello image on app start
- [ ] Character changes to appropriate emotion when mood is selected
- [ ] Character updates when conversation starts
- [ ] All mood types (happy, sad, tired, anxious, okay) have correct images
- [ ] Fallback works for missing emotions
- [ ] Outfit switching works correctly
- [ ] No crashes when changing images rapidly

---

**Date**: February 5, 2026  
**Status**: ✅ Core Implementation Complete  
**Next Steps**: Add outfit2 images and implement outfit selection in customization dialog
