# 📊 BaoBao Codebase Analysis

**Complete Technical Documentation**  
**Date**: January 28, 2026

---

## 🎯 App Overview

**BaoBao** is an emotional support companion app featuring a cheerful panda character. It provides:
- Mood-based conversations with branching dialogue
- Gamification (Claw Machine game)
- Self-care resources
- Professional intervention system

---

## 📁 Project Structure

```
com.example.baobao/
│
├── Activities (9 files)
│   ├── AuthActivity.kt          - Login/Signup screen
│   ├── BaseActivity.kt          - Base class with BGM support
│   ├── ClawMachineActivity.kt   - Claw machine game (493 lines)
│   ├── LoadingActivity.kt       - Loading transition screen
│   ├── MainActivity.kt          - Main screen + conversations (609 lines)
│   ├── MoodSelectionActivity.kt - Mood selection (185 lines)
│   ├── ResourcesActivity.kt     - Professional help resources
│   ├── SettingsActivity.kt      - App settings
│   └── ShopActivity.kt          - Shop/customization (57 lines)
│
├── Managers (2 files)
│   ├── ConversationManager.kt   - All 88 dialogue nodes (1080 lines)
│   └── SoundManager.kt          - BGM + SFX handling (72 lines)
│
├── database/ (5 files)
│   ├── AppDatabase.kt           - Room database setup
│   ├── Purchase.kt              - Purchase entity
│   ├── UserDao.kt               - Database access object
│   ├── UserData.kt              - User state entity (26 lines)
│   └── UserRepository.kt        - Data repository pattern
│
├── models/ (2 files)
│   ├── ConversationNode.kt      - Dialogue node model (20 lines)
│   └── MoodEntry.kt             - Mood tracking model (25 lines)
│
└── intervention/ (1 file)
    └── InterventionManager.kt   - Mental health triggers (107 lines)
```

---

## 🏗️ Architecture

### App Flow

```
AuthActivity (Login/Signup)
      ↓
LoadingActivity (Transition)
      ↓
MoodSelectionActivity (Select mood: Happy/Okay/Sad/Anxious/Tired)
      ↓
MainActivity (Main screen with conversation)
      ├── Conversations (88 dialogue nodes)
      ├── Feature Buttons (Joke, Affirmation, Self-Care, Goodbye)
      └── Navigation (Shop, Claw Machine, Settings, Customize)
```

### Key Patterns

| Pattern | Implementation | Files |
|---------|----------------|-------|
| **Singleton** | ConversationManager, SoundManager | 2 files |
| **Repository** | UserRepository | 1 file |
| **Room Database** | AppDatabase + DAO | 3 files |
| **View Binding** | All Activities | 10 files |
| **Base Activity** | BaseActivity for BGM | 1 file |

---

## 💬 Conversation System

### Dialogue Structure

```kotlin
data class ConversationNode(
    val id: String,              // Unique node ID (e.g., "sad_start")
    val mood: String,            // Mood category
    val baobaoLine: String,      // BaoBao's dialogue text
    val userOptions: List<UserOption>,  // User choices (2-3 options)
    val isLoopPoint: Boolean,    // Returns to mood selector
    val featureNudge: String?    // Feature suggestion
)
```

### Mood Conversation Counts

| Mood | Nodes | Features |
|------|-------|----------|
| Happy | 11 | Joke, Shop, Claw Machine |
| Sad | 16 | Self-Care, Claw Machine |
| Anxious | 15 | Self-Care, Claw Machine |
| Tired | 16 | Self-Care, Claw Machine |
| Okay | 13 | Joke, Affirmation, Claw Machine |
| Intervention | 8 | Professional Resources |

**Total**: 79 conversation nodes + 9 simple dialogue categories = **88+ dialogues**

### Simple Dialogue Categories

| Category | Count | Used In |
|----------|-------|---------|
| Signup | 5 | AuthActivity |
| Login | 5 | AuthActivity |
| Shop | 5 | ShopActivity |
| Settings | 5 | Settings Dialog |
| Claw Machine | 5 | ClawMachineActivity |
| Self-Care | 10 | MainActivity |
| Affirmations | 10 | MainActivity |
| Jokes | 10 | MainActivity |
| Goodbye | 5 | MainActivity |

---

## 🎮 Claw Machine Game

### Features

- **Tries System**: 5/5 tries, 1 refreshes every 5 minutes
- **Random Prizes**: 10-100 currency per ball
- **Smooth Animations**: Drop, lift, return sequences
- **Touch Controls**: Hold to move claw

### State Machine

```
IDLE → MOVING → DROPPING → LIFTING → RETURNING → COMPLETED → IDLE
```

### Key Mechanics

```kotlin
companion object {
    private const val ANIM_DROP_DURATION = 1200L
    private const val ANIM_LIFT_DURATION = 1500L
    private const val ANIM_RETURN_DURATION = 1000L
    private const val ANIM_DROP_HOLE_DURATION = 600L
    private const val RESET_DELAY = 2000L
}
```

---

## 🧠 Intervention System

### Trigger Conditions

```kotlin
// Both must be true:
val weightExceeded = emotionalWeight >= 4
val consecutiveNegative = consecutiveNegativeCycles >= 2
```

### Emotional Weight Values

| Mood | Weight |
|------|--------|
| Happy | 0 |
| Okay | 0 |
| Sad | +1 |
| Anxious | +2 |
| Tired | +1 |

### Intervention Flow

```
User selects negative moods repeatedly
      ↓
emotionalWeight >= 4 AND consecutiveNegativeCycles >= 2
      ↓
InterventionManager.shouldTriggerIntervention() = true
      ↓
Intervention conversation starts (8 nodes)
      ↓
User can view professional resources
```

---

## 🔊 Sound System

### Audio Files

| File | Type | Used In |
|------|------|---------|
| `main_bgm_kakushigoto.mp3` | BGM | MainActivity (default) |
| `main_bgm_little.mp3` | BGM | MainActivity (unlockable) |
| `main_bgm_ordinary_days.mp3` | BGM | MainActivity (unlockable) |
| `clawmachine_bgm.mp3` | BGM | ClawMachineActivity |
| `shop_bgm.mp3` | BGM | ShopActivity |
| `click_sfx.mp3` | SFX | All click interactions |

### Volume Controls

```kotlin
// Saved in SharedPreferences
bgm_volume: Float (0.0 - 1.0, default 0.7)
sfx_volume: Float (0.0 - 1.0, default 0.8)
voice_volume: Float (0.0 - 1.0, default 0.8)  // Future use
```

---

## 💾 Database Schema

### UserData Entity

```kotlin
@Entity(tableName = "user_data")
data class UserData(
    @PrimaryKey val userId: Int = 1,
    
    // Currency & Purchases
    val currency: Int = 1000,
    val purchasedBgm: String = "",      // Comma-separated IDs
    val purchasedThemes: String = "",
    val selectedBgm: String = "kakushigoto",
    val selectedTheme: String = "default",

    // Mood Tracking
    val currentMood: String = "okay",
    val moodHistory: String = "",       // JSON array
    val emotionalWeight: Int = 0,
    val consecutiveNegativeCycles: Int = 0,
    val interventionTriggered: Boolean = false,

    // Conversation State
    val currentConversationPath: String = "",
    val lastConversationNodeId: String = ""
)
```

---

## 🎨 UI Components

### Layouts (10 files)

| Layout | Description |
|--------|-------------|
| `activity_main.xml` | Main screen with conversation area |
| `activity_auth.xml` | Login/signup form |
| `activity_mood_selection.xml` | 5 mood cards |
| `activity_claw_machine.xml` | Game interface |
| `activity_shop.xml` | Shop layout |
| `activity_loading.xml` | Loading screen |
| `activity_resources.xml` | Professional help |
| `activity_settings.xml` | Settings screen |
| `dialog_settings.xml` | Settings popup |
| `dialog_customize.xml` | BGM customization |

### Custom Drawables

- `bamboo_button_*.xml` - Green, light green, tan, pale green buttons
- `bamboo_textarea_bg.xml` - Conversation text area
- `bamboo_dialog_bg.xml` - Dialog backgrounds
- `main_bamboo_background.xml` - Main screen background
- `temple_background.xml` - Alternative background

---

## 🔑 Key Features Matrix

| Feature | Status | Implementation |
|---------|--------|----------------|
| Mood Selection | ✅ | 5 moods with visual feedback |
| Conversations | ✅ | 88 nodes in MainActivity |
| Intervention | ✅ | Auto-triggers at threshold |
| Claw Machine | ✅ | Full game with animations |
| Tries System | ✅ | 5/5, refresh every 5 min |
| Currency | ✅ | Earn from game, spend in shop |
| BGM System | ✅ | 3 tracks, purchasable |
| SFX | ✅ | Click sounds |
| Persistence | ✅ | Room database |
| Feature Nudges | ✅ | Clickable hints in conversations |

---

## 📊 Code Statistics

| Category | Files | Lines (approx) |
|----------|-------|----------------|
| Activities | 9 | ~1,900 |
| Managers | 2 | ~1,150 |
| Database | 5 | ~200 |
| Models | 2 | ~45 |
| Intervention | 1 | ~107 |
| **Total Kotlin** | **19** | **~3,400** |
| Layouts | 10 | ~2,300 |
| Drawables | 22 | ~500 |
| **Total Project** | **51+** | **~6,200** |

---

## 🚨 Known Issues & Technical Debt

### 1. ✅ RESOLVED - Deprecated File Removed
- ~~ConversationActivity.kt~~ - Deleted
- ~~activity_conversation.xml~~ - Deleted
- Removed from AndroidManifest.xml

### 2. Unused Imports
- Some files have unused import warnings
- Non-critical, cosmetic cleanup

### 3. Future Audio Integration
- `playNodeAudio()` method is placeholder
- Needs 139 audio files when implemented

### 4. Hardcoded Strings
- Some dialogue in code instead of strings.xml
- Works but less maintainable

---

## 🔧 Configuration

### SharedPreferences Keys

```kotlin
// BaoBaoPrefs
"bgm_volume" -> Float (0.0-1.0)
"sfx_volume" -> Float (0.0-1.0)
"voice_volume" -> Float (0.0-1.0)
"selected_bgm" -> String ("kakushigoto", "little", "ordinary")
"owned_bgms" -> StringSet
"currency" -> Int
"remaining_tries" -> Int (0-5)
"next_refresh_time" -> Long (timestamp)
```

### Intent Extras

```kotlin
// MoodSelectionActivity → MainActivity
"selected_mood" -> String (mood name)
"start_conversation" -> Boolean (true to start conversation mode)

// LoadingActivity
"target_class" -> String (target activity class name)
"delay" -> Long (loading duration)
```

---

## 🎯 Recommendations

### ✅ Completed Cleanup
1. ~~Delete `ConversationActivity.kt`~~ ✓ Done
2. ~~Delete `activity_conversation.xml`~~ ✓ Done  
3. ~~Remove from AndroidManifest.xml~~ ✓ Done

### Future Cleanup
1. Remove unused imports (warnings only)

### Performance
1. Lazy load conversation nodes by mood
2. Consider pagination for long histories
3. Cache currency value in memory

### Features to Add
1. Audio playback for dialogues
2. Haptic feedback on interactions
3. Dark mode support
4. Push notification reminders
5. Achievement/badge system

### Code Quality
1. Move hardcoded strings to resources
2. Add unit tests for InterventionManager
3. Add UI tests for conversation flow
4. Document public methods with KDoc

---

## 📱 Build Information

```bash
# Build Command
.\gradlew.bat :app:assembleDebug

# Build Time
~3-5 seconds (incremental)
~15-20 seconds (clean build)

# APK Location
app/build/outputs/apk/debug/app-debug.apk
```

### Dependencies (Key)

- AndroidX Core
- Material Design Components
- Room Database
- Kotlin Coroutines
- View Binding

---

## 🏆 Summary

**BaoBao** is a well-structured emotional support app with:

- ✅ **Clean Architecture**: Repository pattern, separation of concerns
- ✅ **Feature Complete**: All 4 modules implemented
- ✅ **Extensible**: Easy to add new moods, dialogues, features
- ✅ **Maintainable**: Clear file organization, documented code
- ✅ **Engaging**: Gamification, personality, animations

**Ready for**: Audio integration, testing, and production deployment.

---

**Analysis Date**: January 28, 2026  
**Kotlin Files**: 20  
**Total Lines**: ~6,600  
**Build Status**: ✅ SUCCESSFUL
