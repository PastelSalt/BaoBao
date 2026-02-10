package com.example.baobao.tutorial

import android.content.Context
import android.content.SharedPreferences

/**
 * 🐼 BaoBao Tutorial Manager
 *
 * Comprehensive guide for all app operations and features.
 * This manager handles tutorial state tracking and provides
 * step-by-step guidance for new users.
 *
 * @author BaoBao Development Team
 * @version 1.0
 * @since February 2026
 */
object TutorialManager {

    private const val PREFS_NAME = "BaoBaoTutorialPrefs"
    private const val KEY_TUTORIAL_COMPLETED = "tutorial_completed"
    private const val KEY_CURRENT_STEP = "current_tutorial_step"
    private const val KEY_FEATURES_UNLOCKED = "features_unlocked"

    // ========================================================================
    // TUTORIAL STEPS ENUM
    // ========================================================================

    /**
     * All tutorial steps in the app, organized by feature area
     */
    enum class TutorialStep(val stepId: Int, val title: String, val description: String) {
        // ---- ONBOARDING ----
        WELCOME(1, "Welcome to BaoBao!",
            "Hi there! I'm BaoBao, your friendly panda companion. I'm here to support you through good days and tough ones alike. Let me show you around!"),

        CREATE_ACCOUNT(2, "Create Your Account",
            "First, let's set up your account. You can sign up with a username and password, or continue as a guest. Your progress will be saved either way!"),

        MEET_BAOBAO(3, "Meet Your Companion",
            "This is me! Tap on me anytime you want to chat. I'll respond differently based on how you're feeling. My outfit might change too!"),

        // ---- MOOD SYSTEM ----
        MOOD_SELECTION(10, "How Are You Feeling?",
            "Tap on me to open the mood selector. Choose how you're feeling right now: Happy, Okay, Sad, Anxious, or Tired. I'll respond with understanding and support."),

        MOOD_TRACKING(11, "Mood Tracking",
            "I keep track of your moods over time. This helps me understand your patterns and offer better support. Don't worry, everything stays private on your device."),

        MOOD_EFFECTS(12, "Mood Effects",
            "Each mood affects our conversation. Happy moods help reduce emotional weight, while sad or anxious moods might increase it. I'll always be here to help balance things out."),

        // ---- CONVERSATION SYSTEM ----
        CONVERSATION_BASICS(20, "Having a Conversation",
            "When you select a mood, we'll start a conversation. I'll share thoughts and you can choose your responses. Each path leads to different supportive moments."),

        CONVERSATION_CHOICES(21, "Making Choices",
            "See those buttons below? Those are your response options. Tap one to continue our chat. There's no wrong answer - just be yourself!"),

        FEATURE_NUDGES(22, "Feature Suggestions",
            "Sometimes I'll suggest trying a feature like jokes or the claw machine. These are gentle nudges - you're always in control of what we do together."),

        CONVERSATION_END(23, "Ending Conversations",
            "Conversations loop back to the mood selector. You can start a new one anytime, or use the feature buttons to do something fun!"),

        // ---- FEATURE BUTTONS ----
        JOKE_BUTTON(30, "Tell Me a Joke!",
            "Tap the joke button to hear one of my panda jokes! I have 10 different ones, each with voice acting. Laughter is good medicine!"),

        AFFIRMATION_BUTTON(31, "Daily Affirmations",
            "Need some encouragement? The affirmation button gives you a positive message. I'll remind you how amazing you are!"),

        SELFCARE_BUTTON(32, "Self-Care Tips",
            "The self-care button offers gentle wellness suggestions. Things like taking breaks, stretching, or just breathing. Small acts of kindness for yourself."),

        GOODBYE_BUTTON(33, "Saying Goodbye",
            "When you're ready to go, tap goodbye. I'll give you a warm send-off. The app will close after a few seconds, but I'll be here when you return!"),

        BUTTON_TOGGLE(34, "Toggle View",
            "See the toggle button? It switches between the menu buttons and conversation choices. Handy when you want quick access to features during a chat!"),

        // ---- NAVIGATION ----
        SETTINGS_BUTTON(40, "Settings",
            "Tap the gear icon to open settings. You can adjust BGM volume, voice volume, and sound effects. Sign out is also here when needed."),

        CUSTOMIZE_BUTTON(41, "Customize",
            "The customize button lets you change my outfit, the background, and the music! You'll need to unlock items in the shop first."),

        SHOP_BUTTON(42, "Visit the Shop",
            "The shop is where you spend your earned currency. Buy new BGM tracks, outfits for me, and beautiful backgrounds!"),

        CLAW_MACHINE_BUTTON(43, "Play Claw Machine",
            "My favorite game! The claw machine lets you win currency. You have 5 tries that regenerate over time. Get lucky and catch the golden prizes!"),

        // ---- SHOP SYSTEM ----
        SHOP_OVERVIEW(50, "Shop Overview",
            "Welcome to the shop! Here you can browse and purchase items using the currency you've earned. Everything is organized by category."),

        SHOP_BGM(51, "Background Music",
            "Music sets the mood! The default BGM is 'Kakushigoto', but you can buy 'Little' and 'Ordinary Days' for variety. Each creates a different atmosphere."),

        SHOP_OUTFITS(52, "Outfits for BaoBao",
            "Want to dress me up? Buy new outfits in the shop. Right now there's 'Blue Bao' - a cool blue version of me! More outfits coming soon."),

        SHOP_BACKGROUNDS(53, "Background Scenes",
            "Change the scenery! Buy beautiful backgrounds like 'Bamboo Clouds' or 'Bamboo Plum' to customize your experience."),

        SHOP_CURRENCY(54, "Earning Currency",
            "You start with 3000✷. Earn more by playing the claw machine! Currency is shown at the top of the shop. Spend wisely... or not, have fun!"),

        // ---- CLAW MACHINE ----
        CLAW_INTRO(60, "Claw Machine Basics",
            "Welcome to the Claw Machine! This is where you can earn currency to spend in the shop. Let me explain how it works."),

        CLAW_CONTROLS(61, "How to Play",
            "Hold the screen to move the claw left and right. Release to drop it! The claw will grab and (hopefully) pick up a prize."),

        CLAW_TRIES(62, "Try System",
            "You have 5 tries. Used one? It regenerates in 5 minutes. Can't wait? You can buy extra tries with currency (50✷ each, up to 10 per day)."),

        CLAW_PRIZES(63, "Prize Values",
            "Regular prizes give 10-50✷. But watch for the golden prizes - they're worth 100✷ or more! Position the claw carefully."),

        CLAW_COMBOS(64, "Combo System",
            "Win multiple times in a row and your combo multiplier increases! 3 wins = 1.2x, 5 wins = 1.5x, 7+ wins = 2x! Keep the streak going!"),

        // ---- CUSTOMIZATION ----
        CUSTOMIZE_OVERVIEW(70, "Customization Overview",
            "In the customize menu, you can personalize your experience. Let's look at what you can change."),

        CUSTOMIZE_SELECT_BGM(71, "Selecting BGM",
            "Tap on any owned BGM to select it. The music will change immediately! You can preview different moods with different tracks."),

        CUSTOMIZE_SELECT_OUTFIT(72, "Changing My Outfit",
            "Tap on an owned outfit to dress me up! I'll appear in my new look on the main screen and in conversations."),

        CUSTOMIZE_SELECT_BG(73, "Changing Background",
            "Tap on an owned background to change the scenery. Each background creates a unique atmosphere for our time together."),

        CUSTOMIZE_SHOP_LINK(74, "Need More Options?",
            "If you want more customization options, the 'Visit Shop' button takes you directly to the shop to browse and buy!"),

        // ---- SETTINGS ----
        SETTINGS_OVERVIEW(80, "Settings Overview",
            "The settings menu lets you control audio and manage your account. Let's walk through the options."),

        SETTINGS_BGM_VOLUME(81, "BGM Volume",
            "Adjust the background music volume with the slider. Set it to 0% for silence, or crank it up to enjoy the full soundtrack!"),

        SETTINGS_SFX_VOLUME(82, "Sound Effects",
            "Control button click sounds and other effects. Each time you adjust, you'll hear a sample of the current volume."),

        SETTINGS_VOICE_VOLUME(83, "Voice Volume",
            "This controls how loud my voice is when I speak. I have over 140 voice lines, so adjust to your preference!"),

        SETTINGS_SIGN_OUT(84, "Signing Out",
            "Ready to leave? The sign out button logs you out and returns to the login screen. Guest accounts are automatically deleted on sign out."),

        // ---- MENTAL HEALTH FEATURES ----
        INTERVENTION_INTRO(90, "When I Notice You're Struggling",
            "I track how you're feeling over time. If I notice you've been having a hard time consistently, I'll gently check in and offer resources."),

        INTERVENTION_TRIGGER(91, "Intervention System",
            "If your emotional weight gets high and you've had several tough mood cycles, I'll suggest professional resources. It's not a judgment - just care."),

        RESOURCES_SCREEN(92, "Crisis Resources",
            "The resources screen provides one-tap access to mental health helplines: Crisis Text Line (741741), 988 Suicide Prevention, SAMHSA, and NAMI."),

        RESOURCES_USAGE(93, "Using Resources",
            "Tap any resource to call or text directly. These are real professionals who can help. Remember: asking for help is a sign of strength."),

        // ---- AUDIO SYSTEM ----
        AUDIO_VOICE_LINES(100, "My Voice",
            "I have over 140 unique voice lines! Each mood conversation, joke, affirmation, and feature has voice acting. Adjust voice volume in settings."),

        AUDIO_BGM_SYSTEM(101, "Background Music",
            "Music plays throughout the app. Different screens have different BGM. Your selected track plays on the main screen and carries your mood."),

        AUDIO_SFX(102, "Sound Effects",
            "Button clicks, game sounds, and other effects add polish to the experience. Adjust SFX volume in settings if they're too loud or quiet."),

        // ---- ACCOUNT FEATURES ----
        ACCOUNT_REGULAR(110, "Regular Accounts",
            "Regular accounts save your progress permanently. Your currency, purchases, mood history, and preferences are all preserved between sessions."),

        ACCOUNT_GUEST(111, "Guest Accounts",
            "Guest accounts let you try the app without signing up. Note: guest data is deleted when you sign out. Consider creating a real account to save progress!"),

        ACCOUNT_SESSION(112, "Session Persistence",
            "Once logged in, you stay logged in! The app remembers your session. Next time you open BaoBao, you'll go straight to the main screen."),

        // ---- COMPLETION ----
        TUTORIAL_COMPLETE(999, "Tutorial Complete!",
            "You're all set! You now know everything about BaoBao. Remember, I'm always here for you - through happy times and hard ones. Let's make today great! 🐼💚");

        companion object {
            fun fromStepId(id: Int): TutorialStep? = entries.find { it.stepId == id }

            fun getStepsForFeature(feature: String): List<TutorialStep> {
                return when (feature.lowercase()) {
                    "onboarding" -> listOf(WELCOME, CREATE_ACCOUNT, MEET_BAOBAO)
                    "mood" -> listOf(MOOD_SELECTION, MOOD_TRACKING, MOOD_EFFECTS)
                    "conversation" -> listOf(CONVERSATION_BASICS, CONVERSATION_CHOICES, FEATURE_NUDGES, CONVERSATION_END)
                    "buttons" -> listOf(JOKE_BUTTON, AFFIRMATION_BUTTON, SELFCARE_BUTTON, GOODBYE_BUTTON, BUTTON_TOGGLE)
                    "navigation" -> listOf(SETTINGS_BUTTON, CUSTOMIZE_BUTTON, SHOP_BUTTON, CLAW_MACHINE_BUTTON)
                    "shop" -> listOf(SHOP_OVERVIEW, SHOP_BGM, SHOP_OUTFITS, SHOP_BACKGROUNDS, SHOP_CURRENCY)
                    "claw" -> listOf(CLAW_INTRO, CLAW_CONTROLS, CLAW_TRIES, CLAW_PRIZES, CLAW_COMBOS)
                    "customize" -> listOf(CUSTOMIZE_OVERVIEW, CUSTOMIZE_SELECT_BGM, CUSTOMIZE_SELECT_OUTFIT, CUSTOMIZE_SELECT_BG, CUSTOMIZE_SHOP_LINK)
                    "settings" -> listOf(SETTINGS_OVERVIEW, SETTINGS_BGM_VOLUME, SETTINGS_SFX_VOLUME, SETTINGS_VOICE_VOLUME, SETTINGS_SIGN_OUT)
                    "mental_health" -> listOf(INTERVENTION_INTRO, INTERVENTION_TRIGGER, RESOURCES_SCREEN, RESOURCES_USAGE)
                    "audio" -> listOf(AUDIO_VOICE_LINES, AUDIO_BGM_SYSTEM, AUDIO_SFX)
                    "account" -> listOf(ACCOUNT_REGULAR, ACCOUNT_GUEST, ACCOUNT_SESSION)
                    else -> emptyList()
                }
            }
        }
    }

    // ========================================================================
    // TUTORIAL STATE MANAGEMENT
    // ========================================================================

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    /**
     * Check if user has completed the full tutorial
     */
    fun isTutorialCompleted(context: Context): Boolean {
        return getPrefs(context).getBoolean(KEY_TUTORIAL_COMPLETED, false)
    }

    /**
     * Mark the tutorial as completed
     */
    fun completeTutorial(context: Context) {
        getPrefs(context).edit().putBoolean(KEY_TUTORIAL_COMPLETED, true).apply()
    }

    /**
     * Reset tutorial progress (for testing or re-learning)
     */
    fun resetTutorial(context: Context) {
        getPrefs(context).edit().apply {
            putBoolean(KEY_TUTORIAL_COMPLETED, false)
            putInt(KEY_CURRENT_STEP, 1)
            putString(KEY_FEATURES_UNLOCKED, "")
            apply()
        }
    }

    /**
     * Get the current tutorial step
     */
    fun getCurrentStep(context: Context): TutorialStep {
        val stepId = getPrefs(context).getInt(KEY_CURRENT_STEP, 1)
        return TutorialStep.fromStepId(stepId) ?: TutorialStep.WELCOME
    }

    /**
     * Advance to the next tutorial step
     */
    fun advanceStep(context: Context): TutorialStep {
        val current = getCurrentStep(context)
        val allSteps = TutorialStep.entries.sortedBy { it.stepId }
        val currentIndex = allSteps.indexOf(current)

        val nextStep = if (currentIndex < allSteps.size - 1) {
            allSteps[currentIndex + 1]
        } else {
            completeTutorial(context)
            TutorialStep.TUTORIAL_COMPLETE
        }

        getPrefs(context).edit().putInt(KEY_CURRENT_STEP, nextStep.stepId).apply()
        return nextStep
    }

    /**
     * Jump to a specific tutorial step
     */
    fun goToStep(context: Context, step: TutorialStep) {
        getPrefs(context).edit().putInt(KEY_CURRENT_STEP, step.stepId).apply()
    }

    /**
     * Mark a feature as "learned" (won't show tutorial for it again)
     */
    fun markFeatureLearned(context: Context, featureName: String) {
        val current = getPrefs(context).getString(KEY_FEATURES_UNLOCKED, "") ?: ""
        val features = current.split(",").filter { it.isNotEmpty() }.toMutableSet()
        features.add(featureName)
        getPrefs(context).edit().putString(KEY_FEATURES_UNLOCKED, features.joinToString(",")).apply()
    }

    /**
     * Check if user has learned a specific feature
     */
    fun hasLearnedFeature(context: Context, featureName: String): Boolean {
        val current = getPrefs(context).getString(KEY_FEATURES_UNLOCKED, "") ?: ""
        return featureName in current.split(",")
    }

    // ========================================================================
    // TUTORIAL CONTENT GENERATORS
    // ========================================================================

    /**
     * Get all tutorial steps organized by category
     */
    fun getAllTutorialCategories(): Map<String, List<TutorialStep>> {
        return mapOf(
            "🎉 Getting Started" to TutorialStep.getStepsForFeature("onboarding"),
            "😊 Mood System" to TutorialStep.getStepsForFeature("mood"),
            "💬 Conversations" to TutorialStep.getStepsForFeature("conversation"),
            "🔘 Feature Buttons" to TutorialStep.getStepsForFeature("buttons"),
            "🧭 Navigation" to TutorialStep.getStepsForFeature("navigation"),
            "🛍️ Shop" to TutorialStep.getStepsForFeature("shop"),
            "🎮 Claw Machine" to TutorialStep.getStepsForFeature("claw"),
            "🎨 Customization" to TutorialStep.getStepsForFeature("customize"),
            "⚙️ Settings" to TutorialStep.getStepsForFeature("settings"),
            "💚 Mental Health" to TutorialStep.getStepsForFeature("mental_health"),
            "🔊 Audio System" to TutorialStep.getStepsForFeature("audio"),
            "👤 Account" to TutorialStep.getStepsForFeature("account")
        )
    }

    /**
     * Get a quick reference guide for a specific screen
     */
    fun getQuickGuide(screen: String): String {
        return when (screen.lowercase()) {
            "main" -> """
                |📱 MAIN SCREEN QUICK GUIDE
                |
                |🐼 Character (Center)
                |   • Tap BaoBao to open mood selection
                |   • Character changes expression based on mood
                |   • Outfit reflects your customization choice
                |
                |💬 Speech Bubble (Above character)
                |   • Shows BaoBao's dialogue
                |   • Updates during conversations
                |
                |🔘 Feature Buttons (Bottom)
                |   • 😂 Joke - Hear a panda joke
                |   • 💪 Affirmation - Get encouragement
                |   • 🧘 Self-Care - Wellness tips
                |   • 👋 Goodbye - Exit the app warmly
                |
                |🔄 Toggle Button
                |   • Switches between menu and conversation choices
                |
                |🧭 Navigation (Top corners)
                |   • ⚙️ Settings (top-left)
                |   • 🎨 Customize (top-right)
                |   • 🛍️ Shop
                |   • 🎮 Claw Machine
            """.trimMargin()

            "shop" -> """
                |🛍️ SHOP QUICK GUIDE
                |
                |💰 Currency Display (Top)
                |   • Shows your current balance
                |   • Starting: 3000✷
                |
                |🎵 BGM Section
                |   • Kakushigoto - Free (default)
                |   • Little - 500✷
                |   • Ordinary Days - 750✷
                |
                |👕 Outfits Section
                |   • Outfit 1 - Free (default)
                |   • Blue Bao - 1000✷
                |
                |🖼️ Backgrounds Section
                |   • Default - Free
                |   • Bamboo Clouds - 300✷
                |   • Bamboo Plum - 400✷
                |
                |💡 Tips
                |   • Owned items show "✓ Owned"
                |   • Can't afford? Item is grayed out
                |   • Play Claw Machine to earn more!
            """.trimMargin()

            "claw" -> """
                |🎮 CLAW MACHINE QUICK GUIDE
                |
                |🕹️ Controls
                |   • HOLD screen to move claw
                |   • RELEASE to drop claw
                |   • Claw grabs and lifts automatically
                |
                |🎯 Tries System
                |   • 5 tries maximum
                |   • 1 try regenerates every 5 minutes
                |   • Buy more: 50✷ each (10/day limit)
                |
                |🏆 Prizes
                |   • Regular: 10-50✷
                |   • Golden (rare): 100✷+
                |   • Catch rate varies by position
                |
                |🔥 Combo Multiplier
                |   • 1-2 wins: 1.0x
                |   • 3-4 wins: 1.2x
                |   • 5-6 wins: 1.5x
                |   • 7+ wins: 2.0x
                |
                |💡 Pro Tips
                |   • Aim for center of prizes
                |   • Golden prizes are worth it!
                |   • Keep streaks for max multiplier
            """.trimMargin()

            "settings" -> """
                |⚙️ SETTINGS QUICK GUIDE
                |
                |🔊 Volume Controls
                |   • BGM: Background music (0-100%)
                |   • SFX: Button clicks, game sounds (0-100%)
                |   • Voice: BaoBao's voice lines (0-100%)
                |
                |🚪 Sign Out
                |   • Logs you out of current account
                |   • Guest accounts are DELETED on sign out
                |   • Regular accounts are preserved
                |
                |💡 Tips
                |   • Changes save automatically
                |   • SFX plays sample when adjusted
                |   • Voice volume affects all voice lines
            """.trimMargin()

            "customize" -> """
                |🎨 CUSTOMIZE QUICK GUIDE
                |
                |🎵 BGM Selection
                |   • Tap owned BGM to select
                |   • Music changes immediately
                |   • Only owned tracks appear here
                |
                |👕 Outfit Selection
                |   • Tap outfit to change BaoBao's look
                |   • Applies to all screens
                |   • Only owned outfits appear
                |
                |🖼️ Background Selection
                |   • Tap background to change scene
                |   • Applies to main screen
                |   • Only owned backgrounds appear
                |
                |🛍️ Need More?
                |   • "Visit Shop" button at bottom
                |   • Goes directly to shop
                |   • Buy new items with currency
            """.trimMargin()

            "conversation" -> """
                |💬 CONVERSATION QUICK GUIDE
                |
                |😊 Starting a Conversation
                |   • Tap BaoBao to open mood selector
                |   • Choose your current mood
                |   • Conversation begins automatically
                |
                |🔘 Making Choices
                |   • Colored buttons = response options
                |   • Each choice leads somewhere different
                |   • No wrong answers!
                |
                |💡 Feature Nudges
                |   • Sometimes BaoBao suggests features
                |   • "Try a joke!" "Visit the shop!"
                |   • Completely optional
                |
                |🔄 Loop Points
                |   • Conversations end at loop points
                |   • Returns to mood check-in
                |   • Start fresh anytime!
                |
                |🔀 Toggle Button
                |   • Switch to menu during conversation
                |   • Access jokes, affirmations anytime
                |   • Switch back to continue chat
            """.trimMargin()

            "mood" -> """
                |😊 MOOD SYSTEM QUICK GUIDE
                |
                |🎭 Five Primary Moods
                |   • 😊 Happy - Feeling good!
                |   • 😐 Okay - Neutral, meh
                |   • 😢 Sad - Feeling down
                |   • 😰 Anxious - Worried, stressed
                |   • 😴 Tired - Drained, exhausted
                |
                |⚖️ Emotional Weight
                |   • Happy: -3 (reduces weight)
                |   • Okay: -2 (reduces weight)
                |   • Tired: +1 (adds weight)
                |   • Sad: +1 (adds weight)
                |   • Anxious: +2 (adds weight)
                |
                |🚨 Intervention Trigger
                |   • Weight reaches threshold (4+)
                |   • Multiple negative moods in a row
                |   • BaoBao offers professional resources
                |
                |💚 Privacy
                |   • All data stays on your device
                |   • No cloud uploads
                |   • Your moods are private
            """.trimMargin()

            "resources" -> """
                |💚 MENTAL HEALTH RESOURCES GUIDE
                |
                |📱 Crisis Text Line
                |   • Text HOME to 741741
                |   • 24/7 support via text
                |   • Free and confidential
                |
                |📞 988 Suicide Prevention
                |   • Call or text 988
                |   • Formerly National Suicide Prevention Lifeline
                |   • 24/7 availability
                |
                |📞 SAMHSA Helpline
                |   • 1-800-662-4357
                |   • Substance abuse & mental health
                |   • 24/7, 365 days
                |
                |📞 NAMI Helpline
                |   • 1-800-950-6264
                |   • Mental health info & support
                |   • Mon-Fri, 10am-10pm ET
                |
                |🌐 Learn More
                |   • Opens MentalHealth.gov
                |   • Additional resources
                |   • Education & support
                |
                |💪 Remember
                |   • Asking for help = strength
                |   • You are not alone
                |   • BaoBao believes in you
            """.trimMargin()

            else -> "No quick guide available for '$screen'."
        }
    }

    // ========================================================================
    // CONTEXTUAL HELP
    // ========================================================================

    /**
     * Get contextual help based on what the user is currently doing
     */
    fun getContextualHelp(context: String, action: String? = null): String {
        return when (context.lowercase()) {
            "auth_login" -> "Enter your username and password, then tap 'Login'. Forgot your password? You'll need to create a new account."

            "auth_signup" -> "Choose a unique username and password. Your data will be saved for future sessions!"

            "auth_guest" -> "Guest accounts are temporary. Your progress will be lost when you sign out. Consider creating an account to save your progress!"

            "mood_happy" -> "Yay! Happy conversations focus on celebrating and maintaining your good mood. Let's keep the positive energy going!"

            "mood_sad" -> "I'm here for you. Sad conversations offer comfort, validation, and gentle support. Take your time."

            "mood_anxious" -> "Anxiety can be overwhelming. Our conversation will focus on grounding and calming techniques. Breathe with me."

            "mood_tired" -> "Rest is important. Tired conversations offer gentle energy and self-care reminders. It's okay to take it slow."

            "mood_okay" -> "Okay is perfectly valid! These conversations are balanced and can go in many directions based on what you need."

            "shop_insufficient" -> "Not enough currency? Play the Claw Machine to earn more! Each prize gives you currency toward your next purchase."

            "shop_already_owned" -> "You already own this item! Go to Customize to equip it."

            "claw_no_tries" -> "Out of tries? Wait 5 minutes for one to regenerate, or purchase more with currency (50✷ each)."

            "claw_daily_limit" -> "You've reached the daily purchase limit (10 tries). Come back tomorrow, or wait for natural regeneration!"

            "intervention" -> "I've noticed you've been having a tough time lately. It's okay to ask for help. Would you like to see some professional resources?"

            else -> "Need help? Tap BaoBao anytime to start a conversation, or use the menu buttons to explore features!"
        }
    }

    // ========================================================================
    // FIRST-TIME FEATURE TUTORIALS
    // ========================================================================

    /**
     * Get first-time tutorial for a specific feature
     * Returns null if user has already learned this feature
     */
    fun getFirstTimeTutorial(context: Context, feature: String): List<TutorialStep>? {
        return if (hasLearnedFeature(context, feature)) {
            null
        } else {
            TutorialStep.getStepsForFeature(feature)
        }
    }

    /**
     * Show and mark a feature as learned
     */
    fun showFeatureTutorial(context: Context, feature: String, onComplete: () -> Unit): List<TutorialStep> {
        val steps = TutorialStep.getStepsForFeature(feature)
        markFeatureLearned(context, feature)
        onComplete()
        return steps
    }

    // ========================================================================
    // UTILITY METHODS
    // ========================================================================

    /**
     * Get total tutorial progress as percentage
     */
    fun getTutorialProgress(context: Context): Float {
        val featuresLearned = getPrefs(context).getString(KEY_FEATURES_UNLOCKED, "")?.split(",")?.filter { it.isNotEmpty() }?.size ?: 0
        val totalFeatures = 12 // Total number of learnable features
        return (featuresLearned.toFloat() / totalFeatures) * 100f
    }

    /**
     * Get list of features still to learn
     */
    fun getUnlearnedFeatures(context: Context): List<String> {
        val allFeatures = listOf("onboarding", "mood", "conversation", "buttons", "navigation", "shop", "claw", "customize", "settings", "mental_health", "audio", "account")
        val learned = getPrefs(context).getString(KEY_FEATURES_UNLOCKED, "")?.split(",")?.filter { it.isNotEmpty() } ?: emptyList()
        return allFeatures.filter { it !in learned }
    }

    /**
     * Debug: Print all tutorial content to log
     */
    fun debugPrintAllContent(): String {
        val builder = StringBuilder()
        builder.appendLine("=== BAOBAO TUTORIAL CONTENT ===\n")

        getAllTutorialCategories().forEach { (category, steps) ->
            builder.appendLine("[$category]")
            steps.forEach { step ->
                builder.appendLine("  ${step.stepId}. ${step.title}")
                builder.appendLine("     ${step.description}")
                builder.appendLine()
            }
        }

        return builder.toString()
    }
}

