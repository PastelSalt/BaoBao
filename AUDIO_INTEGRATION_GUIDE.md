# 🎵 Audio Integration Guide - BaoBao App

## Current Architecture

The conversation system has been refactored to use **ConversationManager** as the central hub:

```
ConversationActivity
        ↓
ConversationManager (manages all conversations + audio in future)
        ↓
ConversationScripts (data layer - stores all 88 conversation nodes)
```

### Why This Architecture?

1. **Centralized Control**: ConversationManager is the single point of access for all dialogue
2. **Audio Ready**: Easy to add audio playback without changing ConversationActivity
3. **Clean Separation**: 
   - **ConversationManager** = Logic + Audio playback
   - **ConversationScripts** = Data only
   - **ConversationActivity** = UI only

---

## How to Add Audio Support

### Step 1: Prepare Audio Files

1. Record BaoBao's voice for each dialogue line
2. Save as MP3 or OGG format
3. Place in `res/raw/` folder with naming convention:
   ```
   res/raw/
   ├── baobao_happy_start.mp3
   ├── baobao_happy_good_thing.mp3
   ├── baobao_sad_start.mp3
   ├── baobao_anxious_start.mp3
   └── ... (88 files total for all nodes)
   ```

### Step 2: Update ConversationNode Model

Add audio resource ID field to the data class:

```kotlin
// File: models/ConversationNode.kt

data class ConversationNode(
    val id: String,
    val mood: String,
    val baobaoLine: String,
    val userOptions: List<UserOption>,
    val isLoopPoint: Boolean = false,
    val featureNudge: String? = null,
    val audioResourceId: Int? = null  // ⭐ NEW: Optional audio file
)
```

### Step 3: Add Audio Resources to Nodes

Update conversation nodes in ConversationScripts.kt:

```kotlin
"happy_start" to ConversationNode(
    id = "happy_start",
    mood = "happy",
    baobaoLine = "That's wonderful to hear! Your happiness is contagious! 🌟",
    userOptions = listOf(/* ... */),
    isLoopPoint = false,
    audioResourceId = R.raw.baobao_happy_start  // ⭐ Add this
),
```

### Step 4: Implement Audio Playback in ConversationManager

```kotlin
// File: ConversationManager.kt

import android.content.Context
import android.media.MediaPlayer

object ConversationManager {
    
    private var currentMediaPlayer: MediaPlayer? = null
    
    /**
     * Play audio for a conversation node
     * Call this when displaying a node in ConversationActivity
     */
    fun playNodeAudio(context: Context, node: ConversationNode) {
        // Stop any currently playing audio
        stopAudio()
        
        // Play new audio if available
        node.audioResourceId?.let { audioResId ->
            try {
                currentMediaPlayer = MediaPlayer.create(context, audioResId)
                currentMediaPlayer?.apply {
                    setOnCompletionListener {
                        // Clean up when audio finishes
                        release()
                        currentMediaPlayer = null
                    }
                    start()
                }
            } catch (e: Exception) {
                // Handle error (e.g., file not found)
                e.printStackTrace()
            }
        }
    }
    
    /**
     * Stop currently playing audio
     */
    fun stopAudio() {
        currentMediaPlayer?.apply {
            if (isPlaying) {
                stop()
            }
            release()
        }
        currentMediaPlayer = null
    }
    
    /**
     * Pause audio playback
     */
    fun pauseAudio() {
        currentMediaPlayer?.apply {
            if (isPlaying) {
                pause()
            }
        }
    }
    
    /**
     * Resume audio playback
     */
    fun resumeAudio() {
        currentMediaPlayer?.apply {
            if (!isPlaying) {
                start()
            }
        }
    }
}
```

### Step 5: Update ConversationActivity to Play Audio

```kotlin
// File: ConversationActivity.kt

private fun showDialogue(node: ConversationNode) {
    currentNode = node
    conversationPath.add(node.id)
    
    // Update BaoBao's dialogue
    binding.dialogueText.text = node.baobaoLine
    
    // ⭐ Play audio for this node
    ConversationManager.playNodeAudio(this, node)
    
    // Animate character
    binding.characterImage.animate()
        // ... existing animation code ...
    
    // ... rest of existing code ...
}

override fun onPause() {
    super.onPause()
    // Pause audio when activity is paused
    ConversationManager.pauseAudio()
}

override fun onResume() {
    super.onResume()
    // Resume audio when activity resumes
    ConversationManager.resumeAudio()
}

override fun onDestroy() {
    super.onDestroy()
    // Stop audio when activity is destroyed
    ConversationManager.stopAudio()
}
```

### Step 6: Add Audio Controls (Optional)

Add UI controls in `activity_conversation.xml`:

```xml
<LinearLayout
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:gravity="center">
    
    <!-- Replay audio button -->
    <ImageButton
        android:id="@+id/replayAudioButton"
        android:layout_width="48dp"
        android:layout_height="48dp"
        android:src="@android:drawable/ic_media_play"
        android:background="?attr/selectableItemBackgroundBorderless"
        android:contentDescription="Replay audio" />
    
    <!-- Skip audio button -->
    <ImageButton
        android:id="@+id/skipAudioButton"
        android:layout_width="48dp"
        android:layout_height="48dp"
        android:src="@android:drawable/ic_media_next"
        android:background="?attr/selectableItemBackgroundBorderless"
        android:contentDescription="Skip audio" />
</LinearLayout>
```

And in ConversationActivity:

```kotlin
private fun setupAudioControls() {
    binding.replayAudioButton.setOnClickListener {
        currentNode?.let { node ->
            ConversationManager.playNodeAudio(this, node)
        }
    }
    
    binding.skipAudioButton.setOnClickListener {
        ConversationManager.stopAudio()
    }
}
```

---

## Implementation Checklist

### Phase 1: Basic Audio
- [ ] Record audio for high-priority nodes (start nodes for each mood)
- [ ] Add audio files to `res/raw/`
- [ ] Add `audioResourceId` field to ConversationNode
- [ ] Implement `playNodeAudio()` in ConversationManager
- [ ] Call `playNodeAudio()` in `showDialogue()`
- [ ] Test with 1-2 moods

### Phase 2: Complete Audio
- [ ] Record audio for all 88 conversation nodes
- [ ] Add audio for intervention nodes
- [ ] Implement audio controls (replay, skip)
- [ ] Add audio settings (volume, speed)
- [ ] Test all conversation paths

### Phase 3: Advanced Features
- [ ] Auto-advance dialogue when audio finishes
- [ ] Synchronized text highlighting during audio
- [ ] Background music that dims during voice
- [ ] Audio caching for better performance
- [ ] Offline audio support

---

## Audio Best Practices

### 1. File Naming Convention
```
baobao_{mood}_{nodeId}.mp3

Examples:
- baobao_happy_start.mp3
- baobao_sad_talk.mp3
- baobao_intervention_start.mp3
```

### 2. Audio Quality
- **Format**: MP3 (128kbps) or OGG (96kbps)
- **Sample Rate**: 44.1kHz
- **Channels**: Mono (sufficient for voice)
- **Duration**: Match text length (2-10 seconds per node)

### 3. Voice Guidelines
- **Tone**: Warm, friendly, supportive (match BaoBao's personality)
- **Pace**: Slightly slower than normal speech
- **Emotion**: Match the mood (cheerful for happy, gentle for sad)
- **Clarity**: Professional recording, no background noise

### 4. File Size Optimization
- 88 nodes × ~100KB per file = ~9MB total
- Consider compression for app size
- Use OGG format for smaller files
- Stream from server for very large audio libraries

---

## Current Status

✅ **ConversationManager** created and integrated  
✅ **Architecture** ready for audio  
✅ **All conversations** flow through ConversationManager  
✅ **Code comments** added for future audio implementation  
⏳ **Audio files** need to be recorded  
⏳ **Audio playback** needs to be implemented  

---

## Testing Audio Integration

### Manual Test Checklist
1. [ ] Audio plays when node is displayed
2. [ ] Audio stops when user makes a choice
3. [ ] Audio pauses when app goes to background
4. [ ] Audio resumes when app returns
5. [ ] Audio stops when conversation ends
6. [ ] No memory leaks from MediaPlayer
7. [ ] Works across all 5 moods
8. [ ] Intervention audio plays correctly
9. [ ] Audio controls (replay, skip) work
10. [ ] Settings allow volume adjustment

---

## Example: Complete Audio-Enabled Node

```kotlin
"happy_start" to ConversationNode(
    id = "happy_start",
    mood = "happy",
    baobaoLine = "That's wonderful to hear! Your happiness is contagious! 🌟 What's been making you smile lately?",
    userOptions = listOf(
        UserOption(
            text = "Something good happened today!",
            nextNodeId = "happy_good_thing",
            moodEffect = 0
        ),
        UserOption(
            text = "Just feeling good overall!",
            nextNodeId = "happy_overall",
            moodEffect = 0
        ),
        UserOption(
            text = "I accomplished something!",
            nextNodeId = "happy_achievement",
            moodEffect = 0
        )
    ),
    isLoopPoint = false,
    featureNudge = null,
    audioResourceId = R.raw.baobao_happy_start  // ⭐ Audio file
)
```

When this node is displayed:
1. Text appears in dialogue box
2. Audio plays: "That's wonderful to hear! Your happiness is contagious!"
3. User reads/listens
4. User selects a choice
5. Audio stops
6. Next node loads with its audio

---

## Benefits of This Architecture

### For Users
- 🎵 BaoBao comes alive with voice
- ♿ Accessible for visually impaired users
- 🌐 Multi-language support possible
- 💚 More engaging and personal experience

### For Developers
- 🔧 Easy to add audio incrementally
- 📊 Audio can be updated without app release
- 🎨 Clean separation of concerns
- 🚀 Scalable to hundreds of nodes

---

## Next Steps

1. **Record Sample Audio**: Start with happy_start, sad_start, anxious_start
2. **Implement Basic Playback**: Get 3 nodes working with audio
3. **User Testing**: See if users prefer audio on/off
4. **Expand Gradually**: Add more audio files over time
5. **Polish**: Add controls, settings, animations

---

**Status**: ✅ Architecture Ready for Audio  
**Next Action**: Record audio files and implement playback  
**Estimated Effort**: 2-3 days for basic implementation

---

For questions or issues, refer to:
- ConversationManager.kt (audio logic)
- ConversationScripts.kt (data layer)
- ConversationActivity.kt (UI integration)
