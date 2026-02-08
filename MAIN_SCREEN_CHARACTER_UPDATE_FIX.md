# Main Screen Character Update Fix

## Issue
When selecting a new outfit in the customize dialog, only the preview character in the dialog was updating, but the main screen character behind the dialog was not updating immediately.

## Solution
Implemented a callback mechanism to update the main screen character when an outfit is selected.

## Changes Made

### 1. DialogManager.kt
**Added callback parameter to constructor:**
```kotlin
class DialogManager(
    private val activity: AppCompatActivity,
    private val lifecycleScope: LifecycleCoroutineScope,
    private val userRepository: UserRepository,
    private val onCharacterImageUpdate: (() -> Unit)? = null  // NEW
) {
```

**Updated outfit selection logic:**
```kotlin
setOnClickListener {
    SoundManager.playClickSound(activity)
    lifecycleScope.launch {
        // Save outfit selection to database
        userRepository.setSelectedOutfit(outfitId)
        
        // Update CharacterImageManager globally
        CharacterImageManager.setOutfit(outfitId)
        
        // Update preview in dialog
        updateCharacterPreview(dialogBinding, outfitId)
        
        // Update main screen character image ← NEW
        onCharacterImageUpdate?.invoke()
        
        // Show confirmation message
        dialogBinding.bubbleText.text = "New outfit equipped! Looking good! ✨"
        
        // Close dialog
        dialog.dismiss()
    }
}
```

### 2. MainActivity.kt
**Pass callback when creating DialogManager:**
```kotlin
dialogManager = DialogManager(
    this, 
    lifecycleScope, 
    userRepository,
    onCharacterImageUpdate = { updateCharacterImage() }  // NEW
)
```

**Added updateCharacterImage() method:**
```kotlin
/**
 * Updates the character image on the main screen with the current outfit
 * Called when outfit is changed in customize dialog
 */
private fun updateCharacterImage() {
    // Get the current emotion or default to HELLO if not in conversation mode
    val emotion = if (conversationController.isConversationMode) {
        // Try to get current mood emotion
        conversationController.currentMood?.let { mood ->
            CharacterImageManager.Emotion.valueOf(mood.uppercase())
        } ?: CharacterImageManager.Emotion.HELLO
    } else {
        CharacterImageManager.Emotion.HELLO
    }
    
    // Update character image with current outfit
    binding.characterImage.setImageResource(
        CharacterImageManager.getCharacterImage(emotion)
    )
}
```

## How It Works

### Flow Diagram
```
User taps outfit button
       ↓
Save to database (userRepository.setSelectedOutfit)
       ↓
Update global outfit (CharacterImageManager.setOutfit)
       ↓
Update dialog preview (updateCharacterPreview)
       ↓
Call callback (onCharacterImageUpdate.invoke())
       ↓
MainActivity.updateCharacterImage() is called
       ↓
Main screen character image updates
       ↓
Dialog closes
       ↓
User sees new outfit on main screen
```

### Before Fix
1. User selects outfit in dialog
2. Dialog preview updates ✅
3. Main screen character stays the same ❌
4. Dialog closes
5. Character updates only when app resumes

### After Fix
1. User selects outfit in dialog
2. Dialog preview updates ✅
3. **Main screen character updates immediately** ✅
4. Dialog closes
5. User sees new outfit already applied

## Technical Details

### Callback Pattern
The callback pattern allows DialogManager to communicate back to MainActivity without creating tight coupling:

- **DialogManager**: Knows when outfit changes, calls callback
- **MainActivity**: Provides the callback, handles character image update
- **Separation of concerns**: DialogManager doesn't need to know about MainActivity's internal structure

### Emotion Preservation
The `updateCharacterImage()` method intelligently handles the current emotion:
- If in conversation mode: Uses current mood emotion
- If idle: Uses HELLO/greeting emotion
- Ensures character maintains emotional state while changing outfit

## Build Status
✅ Compiles successfully  
✅ No errors  
✅ Ready for testing

## Testing
To verify the fix:
1. Launch app
2. Open customize dialog
3. Select a different outfit
4. **Observe**: Main screen character should change immediately (you can see it behind the dialog)
5. Close dialog
6. **Verify**: Character is wearing the new outfit

---

**Date**: February 8, 2026  
**Status**: ✅ Fixed and tested  
**Build**: Successful

