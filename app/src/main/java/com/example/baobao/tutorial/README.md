# 📚 BaoBao Tutorial Package

This package contains the comprehensive tutorial system for the BaoBao app.

## Overview

The `TutorialManager` is a singleton object that handles:
- **Tutorial State Management** - Tracking progress through tutorials
- **Step-by-Step Guidance** - 50+ tutorial steps covering all features
- **Quick Reference Guides** - Screen-specific help text
- **Contextual Help** - Dynamic help based on user actions
- **Feature Learning Tracking** - Remember which features the user has learned

## Files

| File | Description |
|------|-------------|
| `TutorialManager.kt` | Main tutorial manager with all content and logic |
| `README.md` | This documentation file |

## Tutorial Categories

The tutorial system covers 12 main categories:

| Category | Steps | Description |
|----------|-------|-------------|
| 🎉 Onboarding | 3 | Welcome, account creation, meet BaoBao |
| 😊 Mood System | 3 | Mood selection, tracking, effects |
| 💬 Conversations | 4 | Basics, choices, nudges, endings |
| 🔘 Feature Buttons | 5 | Joke, affirmation, self-care, goodbye, toggle |
| 🧭 Navigation | 4 | Settings, customize, shop, claw machine |
| 🛍️ Shop | 5 | Overview, BGM, outfits, backgrounds, currency |
| 🎮 Claw Machine | 5 | Basics, controls, tries, prizes, combos |
| 🎨 Customization | 5 | Overview, BGM, outfit, background selection |
| ⚙️ Settings | 5 | Volume controls, sign out |
| 💚 Mental Health | 4 | Intervention system, resources |
| 🔊 Audio | 3 | Voice lines, BGM, SFX |
| 👤 Account | 3 | Regular, guest, session persistence |

## Usage

### Check Tutorial Completion
```kotlin
if (!TutorialManager.isTutorialCompleted(context)) {
    // Show tutorial
}
```

### Get Current Step
```kotlin
val currentStep = TutorialManager.getCurrentStep(context)
showTutorialDialog(currentStep.title, currentStep.description)
```

### Advance to Next Step
```kotlin
val nextStep = TutorialManager.advanceStep(context)
```

### Get Quick Guide for Screen
```kotlin
val guide = TutorialManager.getQuickGuide("main")
// Returns formatted guide text
```

### Check Feature Learning
```kotlin
if (!TutorialManager.hasLearnedFeature(context, "claw")) {
    TutorialManager.showFeatureTutorial(context, "claw") {
        // Tutorial completed callback
    }
}
```

### Get Contextual Help
```kotlin
val help = TutorialManager.getContextualHelp("mood_sad")
// Returns: "I'm here for you. Sad conversations offer comfort..."
```

### Get Tutorial Progress
```kotlin
val progress = TutorialManager.getTutorialProgress(context)
// Returns: 75.0 (percentage)
```

## TutorialStep Enum

Each step has:
- `stepId: Int` - Unique identifier for persistence
- `title: String` - Short title for the step
- `description: String` - BaoBao's explanation in first person

### Step ID Ranges
| Range | Category |
|-------|----------|
| 1-9 | Onboarding |
| 10-19 | Mood System |
| 20-29 | Conversations |
| 30-39 | Feature Buttons |
| 40-49 | Navigation |
| 50-59 | Shop |
| 60-69 | Claw Machine |
| 70-79 | Customization |
| 80-89 | Settings |
| 90-99 | Mental Health |
| 100-109 | Audio |
| 110-119 | Account |
| 999 | Tutorial Complete |

## Quick Guides Available

- `main` - Main screen guide
- `shop` - Shop screen guide
- `claw` - Claw machine guide
- `settings` - Settings dialog guide
- `customize` - Customize dialog guide
- `conversation` - Conversation system guide
- `mood` - Mood system guide
- `resources` - Mental health resources guide

## Integration Points

The TutorialManager can be integrated with:

1. **First App Launch** - Show onboarding sequence
2. **Feature First Use** - Show feature-specific tutorial
3. **Help Button** - Display quick guides
4. **Contextual Tooltips** - Show relevant help text

## State Persistence

Tutorial state is stored in SharedPreferences (`BaoBaoTutorialPrefs`):
- `tutorial_completed` - Boolean flag
- `current_tutorial_step` - Current step ID
- `features_unlocked` - Comma-separated learned features

## Future Enhancements

- [ ] Add TutorialActivity for visual walkthrough
- [ ] Add overlay highlighting for UI elements
- [ ] Add animated tutorial cards
- [ ] Add voice narration for tutorials
- [ ] Add skip tutorial option
- [ ] Add tutorial replay from settings

---

*Part of the BaoBao Mental Health Companion App*
*Created: February 2026*

