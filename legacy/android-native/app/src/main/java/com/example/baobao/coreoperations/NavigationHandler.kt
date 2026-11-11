package com.example.baobao.coreoperations

import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.R
import com.example.baobao.ShopActivity
import com.example.baobao.additionals.LoadingActivity
import com.example.baobao.audio.SoundManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.games.ClawMachineActivity
import com.google.android.material.button.MaterialButton

/**
 * Handles navigation and button setup for MainActivity
 * Manages action buttons, navigation buttons, and button toggling
 */
class NavigationHandler(
    private val activity: AppCompatActivity,
    private val binding: ActivityMainBinding
) {

    var isShowingStaticButtons = true
        private set

    /**
     * Sets up all navigation buttons (settings, shop, claw machine, customize)
     */
    fun setupNavigation(
        onShowSettings: () -> Unit,
        onShowCustomize: () -> Unit
    ) {
        binding.settingsButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                onShowSettings()
            }
        }

        binding.shopButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                LoadingActivity.startWithTarget(activity, ShopActivity::class.java)
            }
        }

        binding.clawMachineButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                LoadingActivity.startWithTarget(activity, ClawMachineActivity::class.java)
            }
        }

        binding.customizeButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                onShowCustomize()
            }
        }
    }

    /**
     * Sets up action buttons (joke, affirmation, self-care, goodbye)
     */
    fun setupActionButtons(isConversationMode: () -> Boolean) {
        binding.jokeButton.setOnClickListener {
            if (isConversationMode()) return@setOnClickListener
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it)
            val (text, index) = ConversationManager.getRandomJokeWithIndex()
            // Use typewriter animation for text reveal
            binding.conversationText.animateText(text)
            ConversationManager.playSimpleAudio(activity, "joke", index)
        }

        binding.affirmationButton.setOnClickListener {
            if (isConversationMode()) return@setOnClickListener
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it)
            val (text, index) = ConversationManager.getRandomAffirmationWithIndex()
            // Use typewriter animation for text reveal
            binding.conversationText.animateText(text)
            ConversationManager.playSimpleAudio(activity, "affirmation", index)
        }

        binding.selfCareButton.setOnClickListener {
            if (isConversationMode()) return@setOnClickListener
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it)
            val (text, index) = ConversationManager.getRandomSelfCareWithIndex()
            // Use typewriter animation for text reveal
            binding.conversationText.animateText(text)
            ConversationManager.playSimpleAudio(activity, "selfcare", index)
        }

        binding.goodbyeButton.setOnClickListener {
            if (isConversationMode()) return@setOnClickListener
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it)
            val (text, index) = ConversationManager.getRandomGoodbyeWithIndex()
            // Use typewriter animation for text reveal
            binding.conversationText.animateText(text)
            ConversationManager.playSimpleAudio(activity, "goodbye", index)
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                activity.finishAffinity()
            }, 3000)
        }
    }

    /**
     * Sets up the button toggle functionality
     */
    fun setupButtonToggle(isConversationMode: () -> Boolean, onCreateMockChoices: () -> Unit) {
        binding.buttonToggleButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it)
            toggleButtonContainers(isConversationMode(), onCreateMockChoices)
        }
    }

    /**
     * Toggles between static buttons and conversation choices with animation
     */
    fun toggleButtonContainers(isConversationMode: Boolean, onCreateMockChoices: () -> Unit) {
        if (isConversationMode) {
            // In conversation mode: toggle between conversation choices and static buttons
            isShowingStaticButtons = !isShowingStaticButtons

            if (isShowingStaticButtons) {
                AnimationManager.crossFade(binding.conversationChoicesContainer, binding.defaultButtonsContainer)
                binding.buttonToggleButton.text = "💬 Show Choices"
                // Staggered animation for buttons
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    AnimationManager.staggeredFadeIn(binding.defaultButtonsContainer, delayBetween = 50)
                }, 100)
            } else {
                AnimationManager.crossFade(binding.defaultButtonsContainer, binding.conversationChoicesContainer)
                binding.buttonToggleButton.text = "📋 Show Menu"
                // Staggered animation for choices
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    AnimationManager.staggeredPopIn(binding.conversationChoicesContainer, delayBetween = 80)
                }, 100)
            }
        } else {
            // Not in conversation mode: create mock choices for demonstration
            onCreateMockChoices()
            isShowingStaticButtons = !isShowingStaticButtons

            if (isShowingStaticButtons) {
                AnimationManager.crossFade(binding.conversationChoicesContainer, binding.defaultButtonsContainer)
                binding.buttonToggleButton.text = "💬 Show Choices"
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    AnimationManager.staggeredFadeIn(binding.defaultButtonsContainer, delayBetween = 50)
                }, 100)
            } else {
                AnimationManager.crossFade(binding.defaultButtonsContainer, binding.conversationChoicesContainer)
                binding.buttonToggleButton.text = "📋 Show Menu"
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    AnimationManager.staggeredPopIn(binding.conversationChoicesContainer, delayBetween = 80)
                }, 100)
            }
        }
    }

    /**
     * Creates mock conversation choices for demonstration
     */
    fun createMockConversationChoices(onMockChoiceSelected: (String) -> Unit) {
        binding.conversationChoicesContainer.removeAllViews()

        val mockChoices = listOf(
            "How are you today?" to "happy_start",
            "I need some encouragement" to "show_affirmation",
            "Tell me something funny" to "show_joke",
            "I want to try self-care" to "show_selfcare"
        )

        mockChoices.forEachIndexed { index, (text, action) ->
            val button = MaterialButton(activity)
            button.apply {
                this.text = text
                textSize = 15f
                setTextColor(activity.getColor(R.color.white))
                setPadding(16, 16, 16, 16)
                isAllCaps = false
                cornerRadius = 16
                strokeWidth = 3

                val backgroundRes = when (index % 4) {
                    0 -> R.drawable.bamboo_button_green
                    1 -> R.drawable.bamboo_button_light_green
                    2 -> R.drawable.bamboo_button_tan
                    else -> R.drawable.bamboo_button_pale_green
                }
                setBackgroundResource(backgroundRes)
                backgroundTintList = null

                val layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
                )
                layoutParams.setMargins(0, 0, 0, 12)
                this.layoutParams = layoutParams

                setOnClickListener { view ->
                    SoundManager.playClickSound(activity)
                    AnimationManager.buttonPressEffect(view) {
                        onMockChoiceSelected(action)
                    }
                }
            }

            binding.conversationChoicesContainer.addView(button)
        }
    }

    /**
     * Shows conversation mode UI with animations
     */
    fun showConversationModeUI() {
        isShowingStaticButtons = false

        // Animate toggle button appearance
        AnimationManager.popIn(binding.buttonToggleButton, delay = 100)
        binding.buttonToggleButton.text = "📋 Show Menu"

        // Crossfade button containers
        AnimationManager.slideOutDown(binding.defaultButtonsContainer)
        binding.conversationChoicesContainer.visibility = View.VISIBLE
        AnimationManager.slideInUp(binding.conversationChoicesContainer, delay = 150)

        // Staggered animation for choice buttons
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            AnimationManager.staggeredPopIn(binding.conversationChoicesContainer, delayBetween = 80)
        }, 200)
    }

    /**
     * Hides conversation mode UI with animations
     */
    fun hideConversationModeUI() {
        isShowingStaticButtons = true

        // Animate toggle button disappearance
        AnimationManager.popOut(binding.buttonToggleButton)

        // Crossfade button containers
        AnimationManager.slideOutDown(binding.conversationChoicesContainer)
        binding.defaultButtonsContainer.visibility = View.VISIBLE
        AnimationManager.slideInUp(binding.defaultButtonsContainer, delay = 100)

        // Staggered animation for default buttons
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            AnimationManager.staggeredFadeIn(binding.defaultButtonsContainer, delayBetween = 60)
        }, 150)
    }

    /**
     * Initializes the button toggle button visibility with animation
     */
    fun initializeButtonToggle() {
        binding.buttonToggleButton.alpha = 0f
        binding.buttonToggleButton.visibility = View.VISIBLE
        binding.buttonToggleButton.text = "💬 Show Choices"
        AnimationManager.fadeIn(binding.buttonToggleButton, delay = 500)
    }
}

