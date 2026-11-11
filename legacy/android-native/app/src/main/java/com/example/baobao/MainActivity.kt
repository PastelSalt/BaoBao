package com.example.baobao

import android.animation.AnimatorSet
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.lifecycleScope
import com.example.baobao.audio.SoundManager
import com.example.baobao.audio.VoiceManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.coreoperations.AnimationManager
import com.example.baobao.coreoperations.BackgroundManager
import com.example.baobao.coreoperations.BaseActivity
import com.example.baobao.coreoperations.CharacterImageManager
import com.example.baobao.coreoperations.ConversationController
import com.example.baobao.coreoperations.DialogManager
import com.example.baobao.coreoperations.NavigationHandler
import com.example.baobao.coreoperations.TypewriterTextView
import com.example.baobao.coreoperations.UIStateManager
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.SessionManager
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.models.PrimaryMood
import com.example.baobao.optimization.MemoryOptimizer
import kotlinx.coroutines.launch

/**
 * Main activity of BaoBao app
 * Refactored to use manager classes for better maintainability
 */
class MainActivity : BaseActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var userRepository: UserRepository

    // Manager classes for separation of concerns
    private lateinit var dialogManager: DialogManager
    private lateinit var conversationController: ConversationController
    private lateinit var navigationHandler: NavigationHandler
    private lateinit var uiStateManager: UIStateManager

    // Animation
    private var characterIdleAnimator: AnimatorSet? = null

    private val handler = Handler(Looper.getMainLooper())
    private val timeUpdater = object : Runnable {
        override fun run() {
            uiStateManager.updateStatus(conversationController.currentMood)
            handler.postDelayed(this, 1000)
        }
    }

    // Return 0 to skip BaseActivity BGM handling - we'll handle it ourselves from database
    override fun getBgmResource(): Int = 0


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize Session Manager
        SessionManager.init(this)


        // Initialize database
        val database = AppDatabase.getDatabase(this)
        userRepository = UserRepository(database.userDao())

        // Initialize manager classes
        dialogManager = DialogManager(
            this,
            lifecycleScope,
            userRepository,
            onCharacterImageUpdate = { updateCharacterImage() },
            onBackgroundUpdate = { updateBackground() }
        )
        conversationController = ConversationController(this, binding, lifecycleScope, userRepository)
        navigationHandler = NavigationHandler(this, binding)
        uiStateManager = UIStateManager(this, binding, lifecycleScope, userRepository)

        // Set up conversation end callback
        conversationController.onConversationEnd = {
            // Hide conversation UI and return to normal screen
            navigationHandler.hideConversationModeUI()
            // Reset character to default greeting pose
            binding.characterImage.setImageResource(CharacterImageManager.getHelloImage())
            // Show time-based greeting with voice and typewriter effect
            val (greetingText, greetingIndex) = ConversationManager.getTimeBasedGreetingWithIndex()
            binding.conversationText.animateText(greetingText)
            VoiceManager.playVoice(this, VoiceManager.getGreetingAudioId(this, greetingIndex))
            // Note: User will trigger next conversation by tapping BaoBao again
        }

        // Initialize voice settings
        VoiceManager.applySettings(this)

        // Load and apply selected background and outfit
        lifecycleScope.launch {
            // Apply background
            val selectedBackground = userRepository.getSelectedBackground()
            BackgroundManager.setBackground(selectedBackground)
            BackgroundManager.applyBackgroundToView(binding.root, selectedBackground)

            // Apply outfit
            val selectedOutfit = userRepository.getSelectedOutfit()
            CharacterImageManager.setOutfit(selectedOutfit)
            // Set initial character image to hello/greeting with selected outfit
            binding.characterImage.setImageResource(CharacterImageManager.getHelloImage())
        }

        // Get selected mood from intent
        val selectedMood = intent.getStringExtra("selected_mood")
        val shouldStartConversation = intent.getBooleanExtra("start_conversation", false)

        setupUI()
        uiStateManager.updateStatus()

        // Start entrance animations
        startEntranceAnimations()

        // Start conversation mode if mood selected
        if (selectedMood != null && shouldStartConversation) {
            startConversation(selectedMood)
        } else if (selectedMood != null) {
            conversationController.showMoodGreeting(selectedMood)
        } else {
            // Show time-based greeting with voice and typewriter effect
            val (greetingText, greetingIndex) = ConversationManager.getTimeBasedGreetingWithIndex()
            binding.conversationText.animateText(greetingText)
            VoiceManager.playVoice(this, VoiceManager.getGreetingAudioId(this, greetingIndex))
        }
    }

    private fun startEntranceAnimations() {
        // Character entrance animation
        AnimationManager.characterEntrance(binding.characterImage, 600)

        // Start character idle animation after entrance
        handler.postDelayed({
            characterIdleAnimator = AnimationManager.startCharacterIdleAnimation(binding.characterImage)
        }, 700)

        // Navigation buttons staggered animation
        AnimationManager.staggeredSlideIn(binding.navButtons, fromRight = false, delayBetween = 80)

        // Status card slide in from right
        AnimationManager.slideInRight(binding.statusCard, delay = 100)

        // Conversation area slide up
        AnimationManager.slideInUp(binding.conversationArea, delay = 200)

        // Hint text fade in
        AnimationManager.fadeIn(binding.hintText, delay = 400)

        // Button container staggered animation
        AnimationManager.fadeIn(binding.buttonContainer, delay = 300)
        handler.postDelayed({
            AnimationManager.staggeredFadeIn(binding.defaultButtonsContainer, delayBetween = 60)
        }, 350)
    }

    private fun setupUI() {
        // Setup navigation buttons
        navigationHandler.setupNavigation(
            onShowSettings = { dialogManager.showSettingsDialog() },
            onShowCustomize = { dialogManager.showCustomizeDialog() }
        )

        // Setup action buttons
        navigationHandler.setupActionButtons { conversationController.isConversationMode }

        // Setup character interaction with animation
        binding.characterImage.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.characterTapReaction(binding.characterImage)
            if (conversationController.isConversationMode) {
                conversationController.exitConversationMode()
                navigationHandler.hideConversationModeUI()
            }
            showMoodSelectionDialog()
        }

        // Setup tap-to-skip for typewriter animation on conversation area
        binding.conversationArea.setOnClickListener {
            if (binding.conversationText.isCurrentlyAnimating()) {
                binding.conversationText.skipToEnd()
            }
        }

        // Also allow tapping the text itself to skip
        binding.conversationText.setOnClickListener {
            if (binding.conversationText.isCurrentlyAnimating()) {
                binding.conversationText.skipToEnd()
            }
        }

        // Setup button toggle
        navigationHandler.setupButtonToggle(
            isConversationMode = { conversationController.isConversationMode },
            onCreateMockChoices = { createMockConversationChoices() }
        )

        // Initialize toggle button
        navigationHandler.initializeButtonToggle()
    }

    private fun startConversation(mood: String) {
        conversationController.startConversation(mood)
        navigationHandler.showConversationModeUI()
    }

    private fun showMoodSelectionDialog() {
        dialogManager.showMoodSelectionDialog { mood ->
            handleMoodSelection(mood)
        }
    }

    private fun handleMoodSelection(mood: PrimaryMood) {
        // Animate character emotion change
        AnimationManager.characterEmotionChange(binding.characterImage) {
            // Update character image to match the mood at midpoint
            binding.characterImage.setImageResource(
                CharacterImageManager.getCharacterImageForMood(mood.name.lowercase())
            )
        }

        // Start conversation (this will load the proper starting node)
        startConversation(mood.name.lowercase())
    }

    private fun createMockConversationChoices() {
        navigationHandler.createMockConversationChoices { action ->
            handleMockChoice(action)
        }
    }


    private fun handleMockChoice(action: String) {
        when (action) {
            "show_affirmation" -> {
                val (text, index) = ConversationManager.getRandomAffirmationWithIndex()
                binding.conversationText.animateText(text)
                ConversationManager.playSimpleAudio(this, "affirmation", index)
            }
            "show_joke" -> {
                val (text, index) = ConversationManager.getRandomJokeWithIndex()
                binding.conversationText.animateText(text)
                ConversationManager.playSimpleAudio(this, "joke", index)
            }
            "show_selfcare" -> {
                val (text, index) = ConversationManager.getRandomSelfCareWithIndex()
                binding.conversationText.animateText(text)
                ConversationManager.playSimpleAudio(this, "selfcare", index)
            }
            "happy_start" -> {
                showMoodSelectionDialog()
            }
        }
    }

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

    /**
     * Updates the background on the main screen
     * Called when background is changed in customize dialog
     */
    private fun updateBackground() {
        lifecycleScope.launch {
            val selectedBackground = userRepository.getSelectedBackground()
            BackgroundManager.setBackground(selectedBackground)
            BackgroundManager.applyBackgroundToView(binding.root, selectedBackground)
        }
    }

    override fun onResume() {
        super.onResume()
        handler.post(timeUpdater)

        // Resume character idle animation
        characterIdleAnimator?.resume()

        // Resume or play BGM, apply outfit, and apply background
        lifecycleScope.launch {
            // Load and apply selected background
            val selectedBackground = userRepository.getSelectedBackground()
            BackgroundManager.setBackground(selectedBackground)
            BackgroundManager.applyBackgroundToView(binding.root, selectedBackground)

            // Load and apply selected outfit
            val selectedOutfit = userRepository.getSelectedOutfit()
            CharacterImageManager.setOutfit(selectedOutfit)

            // Refresh character image with current outfit
            if (!conversationController.isConversationMode) {
                binding.characterImage.setImageResource(CharacterImageManager.getHelloImage())
            }

            // Load and play selected BGM
            val selectedBgm = userRepository.getSelectedBgm()
            val resId = uiStateManager.getBgmResourceForKey(selectedBgm)
            SoundManager.playBGM(this@MainActivity, resId)
        }
    }

    override fun onPause() {
        super.onPause()
        MemoryOptimizer.removeCallback(handler, timeUpdater)
        SoundManager.pauseBGM()
        // Pause character idle animation
        characterIdleAnimator?.pause()
    }


    override fun onDestroy() {
        super.onDestroy()
        MemoryOptimizer.cleanupHandler(handler)
        VoiceManager.stopVoice()
        // Clean up animations
        characterIdleAnimator?.cancel()
        characterIdleAnimator = null
    }
}