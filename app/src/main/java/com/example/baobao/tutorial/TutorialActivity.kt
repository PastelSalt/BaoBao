package com.example.baobao.tutorial

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.MainActivity
import com.example.baobao.R
import com.example.baobao.additionals.LoadingActivity
import com.example.baobao.audio.SoundManager
import com.example.baobao.audio.VoiceManager
import com.example.baobao.coreoperations.AnimationManager
import com.example.baobao.databinding.ActivityTutorialBinding

/**
 * Tutorial Activity - Shows step-by-step guidance for new users
 */
class TutorialActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTutorialBinding
    private var currentStep: TutorialManager.TutorialStep = TutorialManager.TutorialStep.WELCOME

    companion object {
        private const val TAG = "TutorialActivity"
        const val EXTRA_START_STEP = "start_step"

        /**
         * Start tutorial from beginning
         */
        fun start(context: Context) {
            val intent = Intent(context, TutorialActivity::class.java)
            context.startActivity(intent)
        }

        /**
         * Start tutorial from specific step
         */
        fun startFromStep(context: Context, step: TutorialManager.TutorialStep) {
            val intent = Intent(context, TutorialActivity::class.java).apply {
                putExtra(EXTRA_START_STEP, step.stepId)
            }
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTutorialBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize voice settings
        VoiceManager.applySettings(this)

        // Get starting step
        val startStepId = intent.getIntExtra(EXTRA_START_STEP, 1)
        currentStep = TutorialManager.TutorialStep.fromStepId(startStepId)
            ?: TutorialManager.TutorialStep.WELCOME

        // Save current step
        TutorialManager.goToStep(this, currentStep)

        setupUI()
        displayCurrentStep()

        // Start entrance animations
        startEntranceAnimations()
    }

    private fun startEntranceAnimations() {
        // Progress bar fade in
        AnimationManager.fadeIn(binding.progressBar, delay = 100)
        AnimationManager.fadeIn(binding.progressText, delay = 150)

        // Content card pop in
        AnimationManager.popIn(binding.tutorialCard, delay = 200)
    }

    private fun setupUI() {
        // Next button
        binding.nextButton.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.buttonPressEffect(it) {
                advanceToNextStep()
            }
        }

        // Skip tutorial button
        binding.skipButton.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.buttonPressEffect(it) {
                skipTutorial()
            }
        }

        // Previous button
        binding.previousButton.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.buttonPressEffect(it) {
                goToPreviousStep()
            }
        }
    }

    private fun displayCurrentStep() {
        // Update text content with animation
        AnimationManager.fadeOut(binding.stepTitle, duration = 100, hideAfter = false) {
            binding.stepTitle.text = currentStep.title
            AnimationManager.fadeIn(binding.stepTitle, duration = 200)
        }

        AnimationManager.fadeOut(binding.stepDescription, duration = 100, hideAfter = false) {
            binding.stepDescription.text = currentStep.description
            AnimationManager.fadeIn(binding.stepDescription, duration = 200)
        }

        // Update progress
        val allSteps = TutorialManager.TutorialStep.entries.filter { it.stepId < 999 }
        val currentIndex = allSteps.indexOf(currentStep)
        val progress = ((currentIndex + 1).toFloat() / allSteps.size * 100).toInt()

        binding.progressText.text = "Step ${currentIndex + 1} of ${allSteps.size}"
        binding.progressBar.progress = progress

        // Update button visibility
        binding.previousButton.isEnabled = currentIndex > 0
        binding.previousButton.alpha = if (currentIndex > 0) 1.0f else 0.5f

        // Update next button text
        if (currentIndex == allSteps.size - 1) {
            binding.nextButton.text = "Finish Tutorial"
        } else {
            binding.nextButton.text = "Next"
        }

        // Update icon based on category
        val iconRes = when {
            currentStep.stepId in 1..9 -> R.drawable.happyface_default // Onboarding
            currentStep.stepId in 10..19 -> R.drawable.okayface_default // Mood
            currentStep.stepId in 20..29 -> R.drawable.baobao_main_default // Conversation
            currentStep.stepId in 30..39 -> R.drawable.happyface_default // Buttons
            currentStep.stepId in 40..49 -> R.drawable.ic_settings_bamboo // Navigation
            currentStep.stepId in 50..59 -> R.drawable.ic_shop_bamboo // Shop
            currentStep.stepId in 60..69 -> R.drawable.ic_claw_machine_logo // Claw
            currentStep.stepId in 70..79 -> R.drawable.ic_edit_bamboo // Customize
            currentStep.stepId in 80..89 -> R.drawable.ic_settings_bamboo // Settings
            currentStep.stepId in 90..99 -> R.drawable.sadface_default // Mental Health
            else -> R.drawable.mainscreen_outfit1_fullbody_hello
        }

        // Animate icon change
        AnimationManager.characterEmotionChange(binding.stepIcon) {
            binding.stepIcon.setImageResource(iconRes)
        }
    }

    private fun advanceToNextStep() {
        val allSteps = TutorialManager.TutorialStep.entries.filter { it.stepId < 999 }.sortedBy { it.stepId }
        val currentIndex = allSteps.indexOf(currentStep)

        if (currentIndex < allSteps.size - 1) {
            // Animate out current content, then show next
            AnimationManager.slideOutLeft(binding.tutorialCard, hideAfter = false) {
                currentStep = allSteps[currentIndex + 1]
                TutorialManager.goToStep(this, currentStep)
                displayCurrentStep()
                binding.tutorialCard.translationX = 300f
                AnimationManager.slideInRight(binding.tutorialCard)
            }
        } else {
            // Tutorial complete
            completeTutorial()
        }
    }

    private fun goToPreviousStep() {
        val allSteps = TutorialManager.TutorialStep.entries.filter { it.stepId < 999 }.sortedBy { it.stepId }
        val currentIndex = allSteps.indexOf(currentStep)

        if (currentIndex > 0) {
            // Animate out to right, then show previous step coming from left
            AnimationManager.slideOutRight(binding.tutorialCard, hideAfter = false) {
                currentStep = allSteps[currentIndex - 1]
                TutorialManager.goToStep(this, currentStep)
                displayCurrentStep()
                binding.tutorialCard.translationX = -300f
                AnimationManager.slideInLeft(binding.tutorialCard)
            }
        }
    }

    private fun skipTutorial() {
        // Show confirmation
        androidx.appcompat.app.AlertDialog.Builder(this, R.style.CustomDialogTheme)
            .setTitle("Skip Tutorial?")
            .setMessage("You can always access the tutorial later from the settings menu. Are you sure you want to skip?")
            .setPositiveButton("Skip") { _, _ ->
                TutorialManager.completeTutorial(this)
                goToMainScreen()
            }
            .setNegativeButton("Continue Tutorial", null)
            .show()
    }

    private fun completeTutorial() {
        TutorialManager.completeTutorial(this)

        // Show completion message with celebration
        AnimationManager.celebrationEffect(binding.tutorialCard)

        binding.stepTitle.text = "You're All Set! 🎉"
        binding.stepDescription.text = "You now know everything about BaoBao! Remember, I'm always here for you through happy times and tough ones. Let's make today great! 🐼💚"
        binding.stepIcon.setImageResource(R.drawable.mainscreen_outfit1_fullbody_happy)
        binding.nextButton.text = "Let's Go!"

        // Animate out skip and previous buttons
        AnimationManager.fadeOut(binding.skipButton)
        AnimationManager.fadeOut(binding.previousButton)

        // Bounce the icon
        AnimationManager.bounceIn(binding.stepIcon, delay = 200)

        // Attention pulse on next button
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            AnimationManager.attentionPulse(binding.nextButton, count = 2)
        }, 500)

        // Override next button
        binding.nextButton.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.buttonPressEffect(it) {
                goToMainScreen()
            }
        }
    }

    private fun goToMainScreen() {
        LoadingActivity.startWithTarget(this, MainActivity::class.java, 1500L)
        finish()
    }

    override fun onBackPressed() {
        // Warn user about exiting tutorial
        androidx.appcompat.app.AlertDialog.Builder(this, R.style.CustomDialogTheme)
            .setTitle("Exit Tutorial?")
            .setMessage("Your progress will be saved. You can continue later from the settings menu.")
            .setPositiveButton("Exit") { _, _ ->
                super.onBackPressed()
            }
            .setNegativeButton("Stay", null)
            .show()
    }
}

