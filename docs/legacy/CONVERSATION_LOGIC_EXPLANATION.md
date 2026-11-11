# 🐼 BaoBao Conversation Logic System - Complete Explanation

## Table of Contents
1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Core Components](#core-components)
4. [Conversation Flow](#conversation-flow)
5. [Data Models](#data-models)
6. [Mood-Based Conversation Trees](#mood-based-conversation-trees)
7. [Intervention System](#intervention-system)
8. [State Management](#state-management)
9. [Feature Nudges](#feature-nudges)
10. [Audio Integration (Future)](#audio-integration-future)

---

## Overview

The BaoBao conversation system is a **tree-based dialogue engine** that provides personalized, mood-aware conversations between the user and BaoBao, the panda companion. The system is designed to:

- **Respond empathetically** to user's emotional states
- **Guide users through therapeutic dialogues** with branching choices
- **Track emotional weight** to detect concerning patterns
- **Trigger professional support resources** when needed
- **Loop back to mood check-ins** after each conversation cycle

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                          │
│                         (MainActivity)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     MoodSelectionActivity                       │
│   • User selects one of 5 primary moods                        │
│   • Saves mood entry with timestamp & weight                   │
│   • Triggers conversation mode via Intent extras               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     ConversationManager                         │
│   • Central singleton holding all conversation scripts          │
│   • 88+ conversation nodes across 6 mood pools                 │
│   • Provides random text for various app contexts              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    InterventionManager                          │
│   • Monitors emotional weight thresholds                       │
│   • Tracks consecutive negative cycles                         │
│   • Triggers professional support when needed                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        UserRepository                           │
│   • Room database persistence                                   │
│   • Stores mood history, conversation path, emotional state     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. ConversationManager (`ConversationManager.kt`)

The **central singleton** that manages all dialogue content. It contains:

#### Random Script Pools (Simple Responses)
```kotlin
object ConversationManager {
    // Context-specific random scripts
    private val signupScripts: List<String>      // Welcome messages for new users
    private val loginScripts: List<String>       // Return user greetings
    private val shopScripts: List<String>        // Shop browsing messages
    private val settingsScripts: List<String>    // Settings dialog messages
    private val clawMachineScripts: List<String> // Claw machine game prompts
    private val selfCareScripts: List<String>    // Self-care suggestions (10 scripts)
    private val dailyAffirmationScripts: List<String> // Daily affirmations (10 scripts)
    private val jokeScripts: List<String>        // Panda-themed jokes (10 scripts)
    private val goodbyeScripts: List<String>     // Farewell messages
}
```

#### Mood-Based Conversation Nodes (Tree Structure)
```kotlin
private val happyNodes: Map<String, ConversationNode>       // Happy mood (11 nodes)
private val sadNodes: Map<String, ConversationNode>         // Sad mood (14 nodes)
private val anxiousNodes: Map<String, ConversationNode>     // Anxious mood (15 nodes)
private val tiredNodes: Map<String, ConversationNode>       // Tired mood (14 nodes)
private val okayNodes: Map<String, ConversationNode>        // Okay mood (13 nodes)
private val interventionNodes: Map<String, ConversationNode> // Intervention (7 nodes)
```

#### Key Methods
```kotlin
// Get the complete node map for a mood
fun getScriptPool(mood: String): Map<String, ConversationNode>

// Get the starting node for a mood
fun getStartingNode(mood: String): ConversationNode

// Get a specific node by ID
fun getNodeById(mood: String, nodeId: String): ConversationNode?

// Check if a node is a conversation loop point
fun isLoopPoint(nodeId: String): Boolean

// Random content getters
fun getRandomJoke(): String
fun getRandomAffirmation(): String
fun getRandomSelfCare(): String
// ... etc
```

---

### 2. ConversationNode (`models/ConversationNode.kt`)

The **data structure** representing a single point in the conversation tree:

```kotlin
data class ConversationNode(
    val id: String,              // Unique identifier (e.g., "happy_start")
    val mood: String,            // Parent mood pool (e.g., "happy")
    val baobaoLine: String,      // BaoBao's dialogue text
    val userOptions: List<UserOption>, // User's response choices
    val isLoopPoint: Boolean = false,  // If true, returns to MoodSelection
    val featureNudge: String? = null   // Optional feature suggestion
)

data class UserOption(
    val text: String,            // Button text shown to user
    val nextNodeId: String,      // ID of the next conversation node
    val moodEffect: Int = 0      // Mood adjustment (+positive, -negative)
)
```

#### Node ID Convention
```
{mood}_{descriptor}
Examples:
- happy_start          → Starting node for happy mood
- happy_good_thing     → Response to "Something good happened"
- happy_loop           → Loop point (returns to mood selector)
- sad_comfort          → Comfort response in sad mood
- intervention_start   → Starting node for intervention flow
```

---

### 3. InterventionManager (`intervention/InterventionManager.kt`)

**Emotional intelligence engine** that monitors user wellbeing:

```kotlin
object InterventionManager {
    // Thresholds
    private const val EMOTIONAL_WEIGHT_THRESHOLD = 4
    private const val CONSECUTIVE_NEGATIVE_THRESHOLD = 2
    private const val INTERVENTION_COOLDOWN_MS = 24 * 60 * 60 * 1000L // 24 hours
    private const val MAX_EMOTIONAL_WEIGHT = 10

    // Core Functions
    fun shouldTriggerIntervention(userData: UserData): Boolean
    fun calculateNewEmotionalWeight(currentWeight: Int, moodName: String): Int
    fun calculateConsecutiveNegativeCycles(currentCycles: Int, moodName: String): Int
    fun markInterventionShown(userData: UserData): UserData
    fun resetInterventionIfImproved(userData: UserData, currentMood: String): UserData
    fun isInNegativePattern(userData: UserData): Boolean
    fun getRecentMoods(moodHistory: String, count: Int): List<String>
}
```

#### Emotional Weight Calculation
```kotlin
// Weight changes per mood selection:
"happy"   → -3  // Significantly reduces weight
"okay"    → -2  // Moderately reduces weight
"sad"     → +1  // Adds weight
"anxious" → +2  // Adds more weight
"tired"   → +1  // Adds weight

// Bounds: 0 to 10
newWeight = (currentWeight + change).coerceIn(0, MAX_EMOTIONAL_WEIGHT)
```

#### Intervention Trigger Logic
```kotlin
// Intervention triggers when:
// 1. Emotional weight >= 4 AND
// 2. (Consecutive negative cycles >= 2 OR negative pattern detected)
// 3. Cooldown period (24 hours) has passed since last intervention

val weightExceeded = emotionalWeight >= 4
val consecutiveNegative = consecutiveNegativeCycles >= 2
val inNegativePattern = recentMoods.count { it in ["sad", "anxious", "tired"] } >= 2

return weightExceeded && (consecutiveNegative || inNegativePattern)
```

---

## Conversation Flow

### Complete User Journey

```
┌─────────────────┐
│  AuthActivity   │ ← User login/signup
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ LoadingActivity │ ← Transition with BaoBao animation
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│       MoodSelectionActivity         │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │😊   │ │😐   │ │😢   │ │😰   │   │
│  │Happy│ │Okay │ │Sad  │ │Anxious│ │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│  ┌─────┐                            │
│  │😴   │                            │
│  │Tired│                            │
│  └─────┘                            │
│      ↓ User selects mood            │
│  [Continue] button pressed          │
└────────┬────────────────────────────┘
         │ Intent with:
         │ • selected_mood: String
         │ • start_conversation: true
         ▼
┌─────────────────────────────────────────┐
│            MainActivity                  │
│  ┌─────────────────────────────────┐    │
│  │    startConversation(mood)      │    │
│  │                                  │    │
│  │ 1. Check for intervention        │    │
│  │ 2. Load starting node            │    │
│  │ 3. Show BaoBao's dialogue        │    │
│  │ 4. Display user choices          │    │
│  └────────────────┬────────────────┘    │
│                   │                      │
│                   ▼                      │
│  ┌─────────────────────────────────┐    │
│  │    showConversationNode(node)    │   │
│  │ • Update conversationText        │   │
│  │ • Animate character              │   │
│  │ • Show featureNudge (optional)   │   │
│  │ • Generate choice buttons        │   │
│  └────────────────┬────────────────┘    │
│                   │ User taps choice    │
│                   ▼                      │
│  ┌─────────────────────────────────┐    │
│  │      onUserChoice(nextId)        │   │
│  │                                  │    │
│  │ if (isLoopPoint):                │    │
│  │   → saveConversationState()      │    │
│  │   → returnToMoodSelector()       │    │
│  │ else:                            │    │
│  │   → getNodeById()               │    │
│  │   → applyMoodEffect()           │    │
│  │   → showConversationNode()       │    │
│  └────────────────┬────────────────┘    │
│                   │                      │
│                   ▼                      │
│            Loop back to                  │
│       showConversationNode()            │
│           OR                             │
│       Return to MoodSelection           │
└─────────────────────────────────────────┘
```

### Conversation Entry Point (MainActivity.kt)

```kotlin
private fun startConversation(mood: String) {
    currentMood = mood
    isConversationMode = true
    conversationPath.clear()

    lifecycleScope.launch {
        val userData = userRepository.getUserData()

        // Check if intervention should be triggered
        if (InterventionManager.shouldTriggerIntervention(userData)) {
            currentMood = "intervention"  // Override mood
            val updatedData = InterventionManager.markInterventionShown(userData)
            userRepository.updateUserData(updatedData)
        }

        // Load starting node
        val startingNode = ConversationManager.getStartingNode(currentMood!!)
        showConversationNode(startingNode)
    }
}
```

### User Choice Handler (MainActivity.kt)

```kotlin
private fun onUserChoice(nextNodeId: String, moodEffect: Int) {
    // Special case: Navigate to resources screen
    if (nextNodeId == "show_resources_screen") {
        val intent = Intent(this, ResourcesActivity::class.java)
        startActivity(intent)
        return
    }

    // Check if this choice leads to loop point
    if (nextNodeId == "return_to_mood" || ConversationManager.isLoopPoint(nextNodeId)) {
        saveConversationState()
        returnToMoodSelector()
        return
    }

    // Get the next node
    val nextNode = ConversationManager.getNodeById(currentMood!!, nextNodeId)

    if (nextNode != null) {
        // Apply mood effect if any
        if (moodEffect != 0) {
            applyMoodEffect(moodEffect)
        }
        showConversationNode(nextNode)
    } else {
        // Fallback: return to mood selector if node not found
        returnToMoodSelector()
    }
}
```

---

## Data Models

### PrimaryMood Enum (`models/MoodEntry.kt`)

```kotlin
enum class PrimaryMood(val displayName: String, val emoji: String, val weight: Int) {
    HAPPY("Happy/Good", "😊", 0),
    OKAY("Okay/Meh", "😐", 0),
    SAD("Sad/Down", "😢", 1),
    ANXIOUS("Anxious/Worried", "😰", 2),
    TIRED("Tired/Drained", "😴", 1);

    companion object {
        fun fromString(value: String): PrimaryMood {
            return values().find { it.name.equals(value, ignoreCase = true) } ?: OKAY
        }
    }
}
```

### MoodEntry Data Class (`models/MoodEntry.kt`)

```kotlin
data class MoodEntry(
    val mood: String,      // "happy", "okay", "sad", "anxious", "tired"
    val timestamp: Long,   // Unix timestamp
    val weight: Int        // Emotional weight value
)
```

### UserData Entity (`database/UserData.kt`)

```kotlin
@Entity(tableName = "user_data")
data class UserData(
    @PrimaryKey val userId: Int = 1,
    val currency: Int = 1000,
    val purchasedBgm: String = "",
    val purchasedThemes: String = "",
    val selectedBgm: String = "kakushigoto",
    val selectedTheme: String = "default",

    // Mood tracking
    val currentMood: String = "okay",
    val moodHistory: String = "",           // JSON array of mood entries
    val emotionalWeight: Int = 0,           // Range: 0 to 10
    val consecutiveNegativeCycles: Int = 0,
    val interventionTriggered: Boolean = false,
    val lastInterventionTime: Long = 0L,

    // Conversation state
    val currentConversationPath: String = "", // JSON array of node IDs
    val lastConversationNodeId: String = ""
)
```

---

## Mood-Based Conversation Trees

### Happy Mood Tree (11 nodes)

```
happy_start
├── [Something good happened today!] → happy_good_thing
│   ├── [Let's celebrate! Tell me a joke!] → happy_celebrate_joke
│   │   ├── [Yes! What else can we do?] → happy_whats_next
│   │   └── [I'm good for now, thank you!] → happy_loop ⟳
│   └── [I want to savor this feeling] → happy_savor
│       ├── [Thank you, BaoBao] → happy_loop ⟳
│       └── [What should I do next?] → happy_whats_next
├── [Just feeling good overall!] → happy_overall
│   ├── [Maybe do something fun?] → happy_fun_activity
│   │   └── [Let's play the claw machine!] → happy_loop ⟳
│   └── [Just enjoy the moment] → happy_savor
└── [I accomplished something!] → happy_achievement
    ├── [Feels amazing!] → happy_feels_amazing
    │   ├── [You're the best, BaoBao!] → happy_loop ⟳
    │   └── [What else should I try?] → happy_whats_next
    └── [Proud and relieved!] → happy_proud

happy_loop → [Check in with my mood] → return_to_mood ⟳
```

### Sad Mood Tree (14 nodes)

```
sad_start
├── [I want to talk about it] → sad_talk
│   ├── [Something happened that hurt] → sad_hurt
│   │   ├── [Yes, some comfort please] → sad_comfort
│   │   └── [Maybe help me feel better?] → sad_feel_better
│   └── [I'm just feeling down] → sad_general_down
├── [Just want to feel less alone] → sad_company
│   ├── [Just sit with me] → sad_sit_together
│   │   └── [*takes a deep breath*] → sad_deep_breath
│   └── [A gentle distraction might help] → sad_distraction
└── [I don't know what I need] → sad_unsure
    ├── [Maybe I need comfort] → sad_comfort
    └── [Maybe I need a break] → sad_distraction

sad_loop → [Check in with my mood] → return_to_mood ⟳
```

### Anxious Mood Tree (15 nodes)

```
anxious_start
├── [I want to talk about it] → anxious_talk
│   ├── [Worried about the future] → anxious_future
│   └── [Can't stop overthinking] → anxious_overthinking
├── [I need calming strategies] → anxious_strategies
│   ├── [That helped a bit] → anxious_helped
│   └── [Still feeling anxious] → anxious_still_anxious
└── [Everything feels overwhelming] → anxious_overwhelming
    ├── [I'll try focusing on one thing] → anxious_focus
    └── [I don't know where to start] → anxious_dont_know

anxious_loop → [Check in with my mood] → return_to_mood ⟳
```

### Tired Mood Tree (14 nodes)

```
tired_start
├── [Physically exhausted] → tired_physical
│   ├── [Haven't slept well] → tired_no_sleep
│   └── [Just been doing too much] → tired_too_much
├── [Emotionally drained] → tired_emotional
│   ├── [How do I rest from feelings?] → tired_rest_feelings
│   └── [I'm just overwhelmed] → tired_overwhelmed
└── [Both, honestly] → tired_both
    ├── [Just be here with me] → tired_be_here
    └── [Suggest something gentle] → tired_gentle

tired_loop → [Check in with my mood] → return_to_mood ⟳
```

### Okay Mood Tree (13 nodes)

```
okay_start
├── [Keep it chill] → okay_chill
│   ├── [Let's just hang out] → okay_hang
│   └── [Maybe chat a bit] → okay_chat
├── [Maybe brighten things up] → okay_brighten
│   ├── [Something fun sounds good!] → okay_fun
│   │   ├── [Tell me a joke!] → okay_joke
│   │   ├── [Claw machine!] → okay_loop ⟳
│   │   └── [Check out the shop] → okay_loop ⟳
│   └── [Something uplifting] → okay_uplifting
└── [Just checking in] → okay_checking
    ├── [Pretty steady] → okay_steady
    └── [A bit of everything] → okay_mixed

okay_loop → [Check in with my mood] → return_to_mood ⟳
```

### Intervention Tree (7 nodes)

```
intervention_start
├── [I'm managing okay] → intervention_managing
│   ├── [Yes, show me resources] → intervention_resources
│   │   └── [View Resources] → show_resources_screen (→ ResourcesActivity)
│   └── [Maybe later] → intervention_later
├── [It has been hard] → intervention_hard
│   ├── [What kind of help?] → intervention_more
│   └── [Show me the resources] → intervention_resources
└── [Tell me more] → intervention_more
    ├── [Okay, I'll look at resources] → intervention_resources
    └── [I'm not ready yet] → intervention_not_ready

intervention_complete → [Check in with my mood] → return_to_mood ⟳
```

---

## Intervention System

### Trigger Conditions

The intervention system monitors the user's emotional wellbeing and triggers professional support resources when concerning patterns are detected:

| Condition | Threshold | Description |
|-----------|-----------|-------------|
| Emotional Weight | ≥ 4 | Cumulative weight from negative moods |
| Consecutive Negative Cycles | ≥ 2 | Back-to-back sad/anxious/tired selections |
| Negative Pattern | 2/3 recent | Most recent moods are negative |
| Cooldown | 24 hours | Minimum time between interventions |

### Weight System

```
Mood Selection → Weight Change
─────────────────────────────
Happy          → -3 (healing)
Okay           → -2 (healing)
Sad            → +1 (concern)
Anxious        → +2 (elevated concern)
Tired          → +1 (concern)
```

### Intervention Flow

```
User selects negative mood repeatedly
           │
           ▼
┌──────────────────────────────────┐
│  InterventionManager.            │
│  shouldTriggerIntervention()     │
│                                  │
│  Weight ≥ 4? ─────── No ────────►│ Normal conversation
│      │ Yes                       │
│      ▼                           │
│  Consecutive ≥ 2 OR Pattern? ───►│ Normal conversation
│      │ Yes                       │
│      ▼                           │
│  Cooldown expired? ─── No ──────►│ Normal conversation
│      │ Yes                       │
│      ▼                           │
│  TRIGGER INTERVENTION            │
└──────────────────────────────────┘
           │
           ▼
    Override mood to "intervention"
           │
           ▼
    Show intervention_start node
           │
           ▼
    Guide to ResourcesActivity
```

---

## State Management

### UI State Variables (MainActivity)

```kotlin
private var currentMood: String? = null           // Active mood pool
private var currentNode: ConversationNode? = null // Current dialogue node
private val conversationPath = mutableListOf<String>() // Node history
private var isConversationMode = false            // UI mode flag
private var isShowingStaticButtons = true         // Toggle button state
```

### Database Persistence

Conversation state is saved to Room database:

```kotlin
private fun saveConversationState() {
    lifecycleScope.launch {
        val userData = userRepository.getUserData()
        val pathJson = JSONArray(conversationPath).toString()

        val updatedData = userData.copy(
            currentMood = currentMood ?: "okay",
            currentConversationPath = pathJson,
            lastConversationNodeId = currentNode?.id ?: ""
        )
        userRepository.updateUserData(updatedData)
    }
}
```

---

## Feature Nudges

Feature nudges are **contextual suggestions** that appear during conversations to guide users to app features:

### Nudge Types

| Nudge ID | Description | Target |
|----------|-------------|--------|
| `joke` | Suggests hearing a joke | Shows random joke in conversation text |
| `claw-machine` | Suggests playing the claw game | Navigates to ClawMachineActivity |
| `self-care` | Suggests self-care tips | Shows random self-care suggestion |
| `shop` | Suggests visiting the shop | Navigates to ShopActivity |
| `affirmation` | Suggests daily affirmation | Shows random affirmation |

### Implementation

```kotlin
private fun showFeatureNudge(feature: String) {
    val nudgeText = when (feature) {
        "joke" -> "💡 Want a laugh? Tap here to hear BaoBao's jokes!"
        "claw-machine" -> "💡 Ready for some fun? Try the Claw Machine game!"
        "self-care" -> "💡 Need gentle care? Tap for self-care suggestions!"
        "shop" -> "💡 Curious about customizations? Check out the shop!"
        "affirmation" -> "💡 Need encouragement? Tap for daily affirmations!"
        else -> ""
    }

    if (nudgeText.isNotBlank()) {
        binding.featureNudgeText.text = nudgeText
        binding.featureNudgeCard.visibility = View.VISIBLE
        binding.featureNudgeCard.setOnClickListener {
            navigateToFeature(feature)
        }
    }
}
```

---

## Audio Integration (Future)

The conversation system is designed for audio integration:

### Planned Audio Features

1. **Voice Lines for Each Node** - BaoBao's dialogue can be voiced
2. **Audio Resource IDs** - Each node can reference a raw audio file
3. **MediaPlayer Integration** - Play audio when showing nodes

### Implementation Placeholder

```kotlin
// In ConversationNode (extend the data class):
data class ConversationNode(
    // ... existing fields ...
    val audioResourceId: Int? = null  // Future: R.raw.happy_start_voice
)

// In ConversationManager:
fun playNodeAudio(nodeId: String) {
    // TODO: Implement audio playback
    // val audioResId = getAudioResourceForNode(nodeId)
    // if (audioResId != null) {
    //     val mediaPlayer = MediaPlayer.create(context, audioResId)
    //     mediaPlayer.start()
    // }
}
```

### Audio File Naming Convention

```
Format: {mood}_{node_id}.mp3
Examples:
- happy_start.mp3
- sad_comfort.mp3
- intervention_resources.mp3
```

---

## Summary

The BaoBao conversation system is a sophisticated emotional support engine that:

1. **Branches dynamically** based on user mood and choices
2. **Tracks emotional wellbeing** through accumulated weights
3. **Triggers professional support** when concerning patterns emerge
4. **Loops naturally** back to mood check-ins after conversations
5. **Nudges users** toward helpful app features contextually
6. **Persists state** for continuity across sessions
7. **Is ready for audio** integration with minimal changes

The system prioritizes **user agency** (always offering choices, never demanding actions), **empathetic responses** (validating feelings, using caring language), and **responsible care** (detecting concerning patterns and offering professional resources).

---

*Last Updated: January 29, 2026*
