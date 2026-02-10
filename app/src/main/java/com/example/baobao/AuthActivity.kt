package com.example.baobao

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.BounceInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.OvershootInterpolator
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.baobao.additionals.LoadingActivity
import com.example.baobao.audio.VoiceManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.coreoperations.AnimationManager
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.SessionManager
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityAuthBinding
import com.example.baobao.optimization.MemoryOptimizer
import com.example.baobao.tutorial.TutorialActivity
import com.example.baobao.tutorial.TutorialManager
import kotlinx.coroutines.launch

class AuthActivity : AppCompatActivity() {
    private var binding: ActivityAuthBinding? = null
    private var isSignUp = false
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var userRepository: UserRepository

    // Track all animators for cleanup
    private val activeAnimators = mutableListOf<ValueAnimator>()
    private var floatingAnimator: ObjectAnimator? = null
    private var glowAnimator: ObjectAnimator? = null

    companion object {
        private const val TAG = "AuthActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            binding = ActivityAuthBinding.inflate(layoutInflater)
            binding?.let {
                setContentView(it.root)

                // Initialize database and session
                val database = AppDatabase.getDatabase(this)
                userRepository = UserRepository(database.userDao())
                SessionManager.init(this)

                // Apply voice settings
                VoiceManager.applySettings(this)

                updateUI()
                setupClickListeners()
                startEntranceAnimations()
                startContinuousAnimations()
            } ?: run {
                Log.e(TAG, "Binding initialization failed")
                finish()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in onCreate: ${e.message}", e)
            finish()
        }
    }

    private fun setupClickListeners() {
        val bind = binding ?: return

        // Secret button - click logo to show all accounts
        bind.logoImage.setOnClickListener {
            showAllAccountsDialog()
        }

        // Guest button - continue as guest
        bind.guestButton.setOnClickListener {
            AnimationManager.buttonPressEffect(it) {
                performGuestLogin()
            }
        }

        bind.signupButton.setOnClickListener {
            if (!isDestroyed && !isFinishing) {
                AnimationManager.buttonPressEffect(it) {
                    isSignUp = !isSignUp
                    updateUI()
                    animateCardTransition()
                }
            }
        }

        bind.loginButton.setOnClickListener {
            if (!isDestroyed && !isFinishing) {
                val username = bind.usernameInputLayout.editText?.text.toString().trim()
                val password = bind.passwordInputLayout.editText?.text.toString().trim()

                // Validation
                if (username.isEmpty()) {
                    Toast.makeText(this, "Please enter a username", Toast.LENGTH_SHORT).show()
                    AnimationManager.shake(bind.usernameInputLayout)
                    return@setOnClickListener
                }

                if (password.isEmpty()) {
                    Toast.makeText(this, "Please enter a password", Toast.LENGTH_SHORT).show()
                    AnimationManager.shake(bind.passwordInputLayout)
                    return@setOnClickListener
                }

                AnimationManager.buttonPressEffect(it) {
                    if (isSignUp) {
                        // Sign up flow
                        performSignup(username, password)
                    } else {
                        // Login flow
                        performLogin(username, password)
                    }
                }
            }
        }
    }

    private fun performGuestLogin() {
        lifecycleScope.launch {
            try {
                val guestUser = userRepository.createGuestAccount()
                if (guestUser != null) {
                    // Login as guest
                    SessionManager.login(this@AuthActivity, guestUser.userId, guestUser.username, isGuestAccount = true)
                    Toast.makeText(this@AuthActivity, "Welcome, Guest!", Toast.LENGTH_SHORT).show()

                    // Navigate to Tutorial for first-time guests, otherwise to Main screen
                    if (!TutorialManager.isTutorialCompleted(this@AuthActivity)) {
                        LoadingActivity.startWithTarget(this@AuthActivity, TutorialActivity::class.java, 1500L)
                    } else {
                        LoadingActivity.startWithTarget(this@AuthActivity, MainActivity::class.java, 1500L)
                    }
                    finish()
                } else {
                    Toast.makeText(this@AuthActivity, "Failed to create guest account", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error creating guest account: ${e.message}", e)
                Toast.makeText(this@AuthActivity, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun performLogin(username: String, password: String) {
        animateButtonPress {
            lifecycleScope.launch {
                try {
                    val user = userRepository.login(username, password)
                    if (user != null) {
                        // Login successful
                        SessionManager.login(this@AuthActivity, user.userId, user.username)
                        Toast.makeText(this@AuthActivity, "Welcome back, $username!", Toast.LENGTH_SHORT).show()

                        // Navigate to Main screen
                        LoadingActivity.startWithTarget(this@AuthActivity, MainActivity::class.java, 1500L)
                        finish()
                    } else {
                        // Login failed
                        Toast.makeText(this@AuthActivity, "Invalid username or password", Toast.LENGTH_LONG).show()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error during login: ${e.message}", e)
                    Toast.makeText(this@AuthActivity, "Login error: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun performSignup(username: String, password: String) {
        animateButtonPress {
            lifecycleScope.launch {
                try {
                    val user = userRepository.signup(username, password)
                    if (user != null) {
                        // Signup successful
                        SessionManager.login(this@AuthActivity, user.userId, user.username)
                        Toast.makeText(this@AuthActivity, "Welcome, $username! Account created successfully!", Toast.LENGTH_LONG).show()

                        // Navigate to Tutorial for new users
                        if (!TutorialManager.isTutorialCompleted(this@AuthActivity)) {
                            LoadingActivity.startWithTarget(this@AuthActivity, TutorialActivity::class.java, 1500L)
                        } else {
                            LoadingActivity.startWithTarget(this@AuthActivity, MainActivity::class.java, 1500L)
                        }
                        finish()
                    } else {
                        // Signup failed (username taken)
                        Toast.makeText(this@AuthActivity, "Username already exists. Please choose another.", Toast.LENGTH_LONG).show()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error during signup: ${e.message}", e)
                    Toast.makeText(this@AuthActivity, "Signup error: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun showAllAccountsDialog() {
        lifecycleScope.launch {
            try {
                val allUsers = userRepository.getAllUsers()

                val message = if (allUsers.isEmpty()) {
                    "No accounts found in database.\n\nCreate your first account!"
                } else {
                    buildString {
                        appendLine("📋 All Accounts (${allUsers.size})")
                        appendLine()
                        allUsers.forEach { user ->
                            appendLine("👤 ${user.username}")
                            appendLine("   User ID: ${user.userId}")
                            appendLine("   Currency: ${user.currency} ✷")
                            appendLine("   Created: ${formatDate(user.createdAt)}")
                            appendLine()
                        }
                    }
                }

                AlertDialog.Builder(this@AuthActivity)
                    .setTitle("🔐 Debug: Account List")
                    .setMessage(message)
                    .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                    .show()
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching accounts: ${e.message}", e)
                Toast.makeText(this@AuthActivity, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun formatDate(timestamp: Long): String {
        val sdf = java.text.SimpleDateFormat("MMM dd, yyyy", java.util.Locale.getDefault())
        return sdf.format(java.util.Date(timestamp))
    }

    private fun startEntranceAnimations() {
        val bind = binding ?: return

        // Delay slightly to ensure layout is complete
        handler.postDelayed({
            if (isDestroyed || isFinishing || binding == null) return@postDelayed

            try {
                // Animate speech bubble floating in
                bind.speechBubble.animate()
                    .alpha(1f)
                    .translationY(0f)
                    .setDuration(800)
                    .setInterpolator(BounceInterpolator())
                    .start()

                // Animate logo with scale and fade
                bind.logoImage.animate()
                    .alpha(1f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(1000)
                    .setStartDelay(300)
                    .setInterpolator(OvershootInterpolator(1.1f))
                    .start()

                // Animate auth card sliding up and fading in
                bind.authCard.animate()
                    .alpha(1f)
                    .translationY(0f)
                    .setDuration(800)
                    .setStartDelay(600)
                    .setInterpolator(DecelerateInterpolator())
                    .withEndAction {
                        if (!isDestroyed && !isFinishing) {
                            // After card animation, animate individual elements
                            animateCardContents()
                        }
                    }
                    .start()
            } catch (e: Exception) {
                Log.e(TAG, "Error in entrance animations: ${e.message}", e)
            }
        }, 200)
    }

    private fun animateCardContents() {
        val bind = binding ?: return
        if (isDestroyed || isFinishing) return

        try {
            // Animate form elements one by one
            val elements = listOf(
                bind.usernameInputLayout,
                bind.loginButton
            )

            elements.forEachIndexed { index, element ->
                element.alpha = 0f
                element.translationY = 50f

                element.animate()
                    .alpha(1f)
                    .translationY(0f)
                    .setDuration(400)
                    .setStartDelay((index * 150).toLong())
                    .setInterpolator(DecelerateInterpolator())
                    .start()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error animating card contents: ${e.message}", e)
        }
    }

    private fun startContinuousAnimations() {
        val bind = binding ?: return
        if (isDestroyed || isFinishing) return

        try {
            // Floating animation for speech bubble
            startFloatingAnimation(bind.speechBubble)

            // Subtle glow animation for login button
            startButtonGlowAnimation()
        } catch (e: Exception) {
            Log.e(TAG, "Error starting continuous animations: ${e.message}", e)
        }
    }

    private fun startFloatingAnimation(view: View) {
        if (isDestroyed || isFinishing) return

        try {
            floatingAnimator?.cancel()
            floatingAnimator = ObjectAnimator.ofFloat(view, "translationY", -8f, 8f).apply {
                duration = 3000
                repeatCount = ValueAnimator.INFINITE
                repeatMode = ValueAnimator.REVERSE
                interpolator = AccelerateDecelerateInterpolator()
                start()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in floating animation: ${e.message}", e)
        }
    }

    private fun startButtonGlowAnimation() {
        val bind = binding ?: return
        if (isDestroyed || isFinishing) return

        try {
            glowAnimator?.cancel()
            val pulseAnimator = ObjectAnimator.ofFloat(bind.loginButton, "alpha", 1f, 0.7f, 1f).apply {
                duration = 2000
                repeatCount = ValueAnimator.INFINITE
                interpolator = AccelerateDecelerateInterpolator()
            }

            handler.postDelayed({
                if (!isDestroyed && !isFinishing && binding != null) {
                    glowAnimator = pulseAnimator
                    pulseAnimator.start()
                }
            }, 2000) // Start after entrance animations
        } catch (e: Exception) {
            Log.e(TAG, "Error in glow animation: ${e.message}", e)
        }
    }

    private fun animateCardTransition() {
        val bind = binding ?: return
        if (isDestroyed || isFinishing) return

        try {
            // Animate card scale and slight bounce when switching modes
            val scaleDown = AnimatorSet().apply {
                playTogether(
                    ObjectAnimator.ofFloat(bind.authCard, "scaleX", 1f, 0.95f),
                    ObjectAnimator.ofFloat(bind.authCard, "scaleY", 1f, 0.95f)
                )
                duration = 200
                interpolator = AccelerateDecelerateInterpolator()
            }

            val scaleUp = AnimatorSet().apply {
                playTogether(
                    ObjectAnimator.ofFloat(bind.authCard, "scaleX", 0.95f, 1f),
                    ObjectAnimator.ofFloat(bind.authCard, "scaleY", 0.95f, 1f)
                )
                duration = 300
                interpolator = OvershootInterpolator(1.2f)
            }

            scaleDown.addListener(object : android.animation.AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: android.animation.Animator) {
                    if (!isDestroyed && !isFinishing && binding != null) {
                        scaleUp.start()
                    }
                }
            })

            scaleDown.start()
        } catch (e: Exception) {
            Log.e(TAG, "Error in card transition: ${e.message}", e)
        }
    }

    private fun animateButtonPress(onComplete: () -> Unit) {
        val bind = binding ?: return
        if (isDestroyed || isFinishing) return

        try {
            // Create a satisfying button press animation
            val pressDown = AnimatorSet().apply {
                playTogether(
                    ObjectAnimator.ofFloat(bind.loginButton, "scaleX", 1f, 0.9f),
                    ObjectAnimator.ofFloat(bind.loginButton, "scaleY", 1f, 0.9f),
                    ObjectAnimator.ofFloat(bind.loginButton, "alpha", 1f, 0.8f)
                )
                duration = 150
            }

            val pressUp = AnimatorSet().apply {
                playTogether(
                    ObjectAnimator.ofFloat(bind.loginButton, "scaleX", 0.9f, 1.05f),
                    ObjectAnimator.ofFloat(bind.loginButton, "scaleY", 0.9f, 1.05f),
                    ObjectAnimator.ofFloat(bind.loginButton, "alpha", 0.8f, 1f)
                )
                duration = 200
                interpolator = OvershootInterpolator(1.5f)
            }

            val settle = AnimatorSet().apply {
                playTogether(
                    ObjectAnimator.ofFloat(bind.loginButton, "scaleX", 1.05f, 1f),
                    ObjectAnimator.ofFloat(bind.loginButton, "scaleY", 1.05f, 1f)
                )
                duration = 150
                interpolator = DecelerateInterpolator()
            }

            pressDown.addListener(object : android.animation.AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: android.animation.Animator) {
                    if (!isDestroyed && !isFinishing && binding != null) {
                        pressUp.start()
                    }
                }
            })

            pressUp.addListener(object : android.animation.AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: android.animation.Animator) {
                    if (!isDestroyed && !isFinishing && binding != null) {
                        settle.start()
                    }
                }
            })

            settle.addListener(object : android.animation.AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: android.animation.Animator) {
                    if (!isDestroyed && !isFinishing) {
                        onComplete()
                    }
                }
            })

            pressDown.start()
        } catch (e: Exception) {
            Log.e(TAG, "Error in button press animation: ${e.message}", e)
            // If animation fails, still execute callback
            onComplete()
        }
    }

    private fun updateUI() {
        val bind = binding ?: return

        if (isSignUp) {
            bind.loginButton.text = "Sign Up"
            bind.signupButton.text = "Already have an account? Login"
            val (text, index) = ConversationManager.getRandomSignupWithIndex()
            animateTextReveal(bind.bubbleText, text)
            VoiceManager.playVoice(this, VoiceManager.getSignupAudioId(this, index))
        } else {
            bind.loginButton.text = "Login"
            bind.signupButton.text = "Don't have an account? Sign Up"
            val (text, index) = ConversationManager.getRandomLoginWithIndex()
            animateTextReveal(bind.bubbleText, text)
            VoiceManager.playVoice(this, VoiceManager.getLoginAudioId(this, index))
        }
    }

    private fun animateTextReveal(textView: android.widget.TextView, fullText: String) {
        if (isDestroyed || isFinishing) return

        try {
            // Clear any existing text
            textView.text = ""

            // Cancel any pending text animations
            handler.removeCallbacksAndMessages(textView)

            // Reveal text character by character
            var currentIndex = 0
            val revealDelay = 30L // milliseconds per character

            val revealRunnable = object : Runnable {
                override fun run() {
                    if (isDestroyed || isFinishing || binding == null) return

                    if (currentIndex <= fullText.length) {
                        textView.text = fullText.substring(0, currentIndex)
                        currentIndex++
                        handler.postDelayed(this, revealDelay)
                    }
                }
            }

            handler.postDelayed(revealRunnable, revealDelay)
        } catch (e: Exception) {
            Log.e(TAG, "Error in text reveal animation: ${e.message}", e)
            // Fallback to showing full text immediately
            textView.text = fullText
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        MemoryOptimizer.cleanupHandler(handler)
        VoiceManager.stopVoice()
    }
}