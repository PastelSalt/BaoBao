# 🎵 Voice Integration Complete - BaoBao App

## Summary

Voice lines have been successfully integrated into the BaoBao app. All 139 audio files are now properly set up and will play automatically when BaoBao speaks.

---

## Audio Files Structure

All audio files are located in `app/src/main/res/raw/` with the following naming convention:

### Simple Features (60 files)
| Section | Files | Description |
|---------|-------|-------------|
| Sign-Up | `a_01.aac` - `a_05.aac` | New user registration dialogue |
| Login | `b_01.aac` - `b_05.aac` | Returning user welcome dialogue |
| Shop | `c_01.aac` - `c_05.aac` | Shopping screen dialogue |
| Settings | `d_01.aac` - `d_05.aac` | Settings dialog dialogue |
| Self-Care | `e_01.aac` - `e_10.aac` | Self-care suggestions |
| Affirmations | `f_01.aac` - `f_10.aac` | Daily affirmation messages |
| Jokes | `g_01.aac` - `g_10.aac` | Panda jokes and puns |
| Claw Machine | `h_01.aac` - `h_05.aac` | Game-specific dialogue |
| Goodbye | `i_01.aac` - `i_05.aac` | Farewell messages |

### Mood Conversations (79 files)
| Mood | Files | Description |
|------|-------|-------------|
| Happy | `h_happy_01.aac` - `h_happy_11.aac` | Happy mood conversation nodes |
| Sad | `s_sad_01.aac` - `s_sad_16.aac` | Sad mood conversation nodes |
| Anxious | `x_anxious_01.aac` - `x_anxious_15.aac` | Anxious mood conversation nodes |
| Tired | `t_tired_01.aac` - `t_tired_16.aac` | Tired mood conversation nodes |
| Okay | `o_okay_01.aac` - `o_okay_13.aac` | Okay mood conversation nodes |
| Intervention | `int_01.aac` - `int_08.aac` | Professional support dialogue |

**Total: 139 audio files**

---

## New Components

### VoiceManager.kt
A new singleton object that handles all voice line playback:

```kotlin
object VoiceManager {
    // Play voice by resource ID
    fun playVoice(context: Context, resId: Int)
    
    // Play voice by resource name
    fun playVoiceByName(context: Context, resourceName: String)
    
    // Stop/pause/resume voice
    fun stopVoice()
    fun pauseVoice()
    fun resumeVoice()
    
    // Volume control
    fun setVolume(volume: Float)
    fun setEnabled(enabled: Boolean)
    
    // Apply settings from SharedPreferences
    fun applySettings(context: Context)
    
    // Get audio resource IDs for each section
    fun getSignupAudioId(context: Context, index: Int): Int
    fun getLoginAudioId(context: Context, index: Int): Int
    fun getShopAudioId(context: Context, index: Int): Int
    fun getSettingsAudioId(context: Context, index: Int): Int
    fun getSelfCareAudioId(context: Context, index: Int): Int
    fun getAffirmationAudioId(context: Context, index: Int): Int
    fun getJokeAudioId(context: Context, index: Int): Int
    fun getClawMachineAudioId(context: Context, index: Int): Int
    fun getGoodbyeAudioId(context: Context, index: Int): Int
    
    // Get audio for mood conversation nodes
    fun getMoodAudioId(context: Context, nodeId: String, mood: String): Int
    fun playNodeVoice(context: Context, nodeId: String, mood: String)
}
```

---

## ConversationManager Updates

Added `WithIndex` versions of all script getters that return both the text and the 1-based index for audio playback:

```kotlin
// Example usage
val (text, audioIndex) = ConversationManager.getRandomJokeWithIndex()
binding.conversationText.text = text
VoiceManager.playVoice(context, VoiceManager.getJokeAudioId(context, audioIndex))
```

New functions added:
- `getRandomSignupWithIndex()`: Returns Pair<String, Int>
- `getRandomLoginWithIndex()`: Returns Pair<String, Int>
- `getRandomShopWithIndex()`: Returns Pair<String, Int>
- `getRandomSettingsWithIndex()`: Returns Pair<String, Int>
- `getRandomClawMachineWithIndex()`: Returns Pair<String, Int>
- `getRandomSelfCareWithIndex()`: Returns Pair<String, Int>
- `getRandomAffirmationWithIndex()`: Returns Pair<String, Int>
- `getRandomJokeWithIndex()`: Returns Pair<String, Int>
- `getRandomGoodbyeWithIndex()`: Returns Pair<String, Int>
- `getClawMachineMoveIndex()`: Returns Int (2)
- `getClawMachineWinIndex()`: Returns Int (3)
- `getClawMachineLossIndex()`: Returns Int (4)
- `getClawMachineRepeatIndex()`: Returns Int (5)

---

## Activities Updated

### MainActivity.kt
- Voice plays when showing conversation nodes
- Voice plays for mood greeting when entering without conversation mode
- Voice plays for joke, affirmation, self-care, and goodbye buttons
- Voice plays in settings dialog
- VoiceManager.applySettings() called on create
- VoiceManager.pauseVoice() called on pause
- VoiceManager.stopVoice() called on destroy
- Voice slider now controls VoiceManager volume

### MoodSelectionActivity.kt
- Voice plays when entering mood selection screen (login greeting)
- Voice plays when a mood is selected (mood start voice)
- VoiceManager lifecycle management added

### AuthActivity.kt
- Voice plays for signup/login greetings

### ShopActivity.kt
- Voice plays for shop greeting

### ClawMachineActivity.kt
- Voice plays for all claw machine states:
  - Initial greeting
  - Moving state
  - Win state
  - Loss state
  - Repeat prompt
  - Reset greeting
- VoiceManager lifecycle management added

---

## Settings Integration

Voice volume is controlled via the Settings dialog:
- Stored in SharedPreferences as `voice_volume` (0.0 to 1.0)
- Can be enabled/disabled with `voice_enabled` boolean
- VoiceManager.applySettings() reads these values

---

## Node ID to Audio File Mapping

### Happy Mood
| Node ID | Audio File |
|---------|------------|
| happy_start | h_happy_01.aac |
| happy_good_thing | h_happy_02.aac |
| happy_overall | h_happy_03.aac |
| happy_achievement | h_happy_04.aac |
| happy_celebrate_joke | h_happy_05.aac |
| happy_savor | h_happy_06.aac |
| happy_fun_activity | h_happy_07.aac |
| happy_feels_amazing | h_happy_08.aac |
| happy_proud | h_happy_09.aac |
| happy_whats_next | h_happy_10.aac |
| happy_loop | h_happy_11.aac |

### Sad Mood
| Node ID | Audio File |
|---------|------------|
| sad_start | s_sad_01.aac |
| sad_talk | s_sad_02.aac |
| sad_company | s_sad_03.aac |
| sad_unsure | s_sad_04.aac |
| sad_hurt | s_sad_05.aac |
| sad_general_down | s_sad_06.aac |
| sad_sit_together | s_sad_07.aac |
| sad_distraction | s_sad_08.aac |
| sad_comfort | s_sad_09.aac |
| sad_feel_better | s_sad_10.aac |
| sad_deep_breath | s_sad_11.aac |
| sad_self_care | s_sad_12.aac |
| sad_playful | s_sad_13.aac |
| sad_trying | s_sad_14.aac |
| sad_still_struggling | s_sad_15.aac |
| sad_loop | s_sad_16.aac |

### Anxious Mood
| Node ID | Audio File |
|---------|------------|
| anxious_start | x_anxious_01.aac |
| anxious_talk | x_anxious_02.aac |
| anxious_strategies | x_anxious_03.aac |
| anxious_overwhelming | x_anxious_04.aac |
| anxious_future | x_anxious_05.aac |
| anxious_overthinking | x_anxious_06.aac |
| anxious_helped | x_anxious_07.aac |
| anxious_still_anxious | x_anxious_08.aac |
| anxious_focus | x_anxious_09.aac |
| anxious_dont_know | x_anxious_10.aac |
| anxious_grounding | x_anxious_11.aac |
| anxious_wont_stop | x_anxious_12.aac |
| anxious_distraction | x_anxious_13.aac |
| anxious_keep_talking | x_anxious_14.aac |
| anxious_loop | x_anxious_15.aac |

### Tired Mood
| Node ID | Audio File |
|---------|------------|
| tired_start | t_tired_01.aac |
| tired_physical | t_tired_02.aac |
| tired_emotional | t_tired_03.aac |
| tired_both | t_tired_04.aac |
| tired_no_sleep | t_tired_05.aac |
| tired_too_much | t_tired_06.aac |
| tired_rest_feelings | t_tired_07.aac |
| tired_overwhelmed | t_tired_08.aac |
| tired_be_here | t_tired_09.aac |
| tired_gentle | t_tired_10.aac |
| tired_try_sleep | t_tired_11.aac |
| tired_tried_everything | t_tired_12.aac |
| tired_guilty | t_tired_13.aac |
| tired_something_light | t_tired_14.aac |
| tired_just_talk | t_tired_15.aac |
| tired_loop | t_tired_16.aac |

### Okay Mood
| Node ID | Audio File |
|---------|------------|
| okay_start | o_okay_01.aac |
| okay_chill | o_okay_02.aac |
| okay_brighten | o_okay_03.aac |
| okay_checking | o_okay_04.aac |
| okay_hang | o_okay_05.aac |
| okay_chat | o_okay_06.aac |
| okay_fun | o_okay_07.aac |
| okay_uplifting | o_okay_08.aac |
| okay_steady | o_okay_09.aac |
| okay_mixed | o_okay_10.aac |
| okay_joke | o_okay_11.aac |
| okay_more_affirmations | o_okay_12.aac |
| okay_loop | o_okay_13.aac |

### Intervention
| Node ID | Audio File |
|---------|------------|
| intervention_start | int_01.aac |
| intervention_managing | int_02.aac |
| intervention_hard | int_03.aac |
| intervention_more | int_04.aac |
| intervention_resources | int_05.aac |
| intervention_later | int_06.aac |
| intervention_not_ready | int_07.aac |
| intervention_complete | int_08.aac |

---

## Testing Checklist

- [ ] Voice plays on AuthActivity (signup/login)
- [ ] Voice plays on ShopActivity
- [ ] Voice plays on ClawMachineActivity (all states)
- [ ] Voice plays in Settings dialog
- [ ] Voice plays for joke button
- [ ] Voice plays for affirmation button
- [ ] Voice plays for self-care button
- [ ] Voice plays for goodbye button
- [ ] Voice plays during mood conversations
- [ ] Voice volume slider works correctly
- [ ] Voice pauses when app goes to background
- [ ] Voice stops when activity is destroyed

---

## Technical Notes

1. **Audio Format**: All files are AAC format (.aac)
2. **Android Raw Resources**: Files must be at the root of `res/raw/` (no subfolders)
3. **Resource Naming**: Android resource names cannot contain hyphens; underscores are used
4. **MediaPlayer**: VoiceManager uses MediaPlayer for playback with proper lifecycle management
5. **Memory Management**: MediaPlayer is released on completion and activity destruction

---

**Last Updated**: February 2, 2026
**Status**: ✅ COMPLETE
**Total Voice Lines**: 139
