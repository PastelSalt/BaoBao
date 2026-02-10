package com.example.baobao.games

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import android.view.animation.OvershootInterpolator
import android.widget.FrameLayout
import android.widget.TextView
import androidx.lifecycle.lifecycleScope
import com.example.baobao.MainActivity
import com.example.baobao.R
import com.example.baobao.additionals.LoadingActivity
import com.example.baobao.audio.SoundManager
import com.example.baobao.audio.VoiceManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.coreoperations.BaseActivity
import com.example.baobao.coreoperations.CharacterImageManager
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityClawMachineBinding
import com.example.baobao.optimization.MemoryOptimizer
import com.example.baobao.optimization.CacheManager
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.abs
import kotlin.math.min
import kotlin.random.Random

class ClawMachineActivity : BaseActivity() {

    // View Binding
    private lateinit var binding: ActivityClawMachineBinding

    // Database
    private lateinit var userRepository: UserRepository

    // Haptic Feedback
    private lateinit var vibrator: Vibrator

    // Game State
    private enum class GameState {
        IDLE, MOVING, DROPPING, LIFTING, RETURNING, COMPLETED
    }
    private var currentState = GameState.IDLE

    // Claw Movement (Enhanced with ValueAnimator)
    private var clawX = 0f
    private var moveDirection = 1
    private val moveSpeed = 15f // Increased for better responsiveness
    private var movementAnimator: ValueAnimator? = null

    // Animation
    private var currentAnimator: ValueAnimator? = null
    private var caughtPrize: View? = null
    private var caughtPrizeValue: Int = 0
    private var isPrizeSpecial: Boolean = false // Track if caught prize is special
    private var caughtPrizeInitialX: Float = 0f // Store initial X for animation
    private var caughtPrizeInitialY: Float = 0f // Store initial Y for animation

    // Prize currency values
    private val prizeValues = mutableMapOf<View, Int>()
    private val specialPrizes = mutableSetOf<View>() // Track special high-value prizes

    // Combo System
    private var consecutiveWins = 0
    private val comboMultiplier: Float
        get() = when (consecutiveWins) {
            in 1..2 -> 1.0f
            in 3..4 -> 1.2f
            in 5..6 -> 1.5f
            else -> 2.0f // 7+ wins
        }

    // Statistics (Persistent)
    private var totalPlays = 0
    private var totalWins = 0
    private var totalEarnings = 0
    private var highestSingleWin = 0

    // Handlers
    private val handler = Handler(Looper.getMainLooper())
    private val moveRunnable = object : Runnable {
        override fun run() {
            if (currentState == GameState.MOVING) {
                updateClawPosition()
                handler.postDelayed(this, 16) // ~60 FPS
            }
        }
    }

    // Tries System
    private var remainingTries = 5
    private val maxTries = 5
    private val tryRefreshIntervalMs = 5 * 60 * 1000L // 5 minutes
    private var nextTryRefreshTime = 0L
    private val timerUpdateRunnable = object : Runnable {
        override fun run() {
            updateTriesTimer()
            handler.postDelayed(this, 1000) // Update every second
        }
    }

    // Purchase Tries System
    private var dailyPurchasesRemaining = 10
    private val maxDailyPurchases = 10
    private val tryCost = 50 // Currency cost per try
    private var lastPurchaseDate = ""

    // Constants
    companion object {
        private const val PREFS_NAME = "BaoBaoPrefs"
        private const val KEY_TRIES = "remaining_tries"
        private const val KEY_NEXT_REFRESH = "next_refresh_time"
        private const val KEY_TOTAL_PLAYS = "claw_total_plays"
        private const val KEY_TOTAL_WINS = "claw_total_wins"
        private const val KEY_TOTAL_EARNINGS = "claw_total_earnings"
        private const val KEY_HIGHEST_WIN = "claw_highest_win"
        private const val KEY_DAILY_PURCHASES = "daily_purchases_remaining"
        private const val KEY_LAST_PURCHASE_DATE = "last_purchase_date"

        private const val ANIM_DROP_DURATION = 1000L // Slightly faster
        private const val ANIM_LIFT_DURATION = 1200L // Faster
        private const val ANIM_RETURN_DURATION = 900L
        private const val ANIM_DROP_HOLE_DURATION = 500L
        private const val RESET_DELAY = 1800L // Faster reset

        private const val SPECIAL_PRIZE_CHANCE = 0.15f // 15% chance for special prize
        private const val CATCH_TOLERANCE = 1.3f // Slightly more forgiving
    }

    override fun getBgmResource(): Int = R.raw.clawmachine_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityClawMachineBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize vibrator
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        // Initialize database
        val database = AppDatabase.getDatabase(this)
        userRepository = UserRepository(database.userDao())

        // Load statistics
        loadStatistics()

        // Apply voice settings
        VoiceManager.applySettings(this)

        // Load and apply selected outfit to character icon
        lifecycleScope.launch {
            val selectedOutfit = userRepository.getSelectedOutfit()
            CharacterImageManager.setOutfit(selectedOutfit)
            // Update character icon with current outfit
            binding.characterIcon.setImageResource(
                CharacterImageManager.getCharacterImage(CharacterImageManager.Emotion.HELLO)
            )
        }

        initializeGame()
    }

    private fun initializeGame() {
        // Load tries system
        loadTriesData()
        loadPurchaseData()
        updateTriesDisplay()
        updatePurchaseDisplay()

        // Setup UI
        binding.backButton.setOnClickListener {
            SoundManager.playClickSound(this)
            goBackWithLoading()
        }

        // Setup buy tries button
        binding.buyTriesButton.setOnClickListener {
            SoundManager.playClickSound(this)
            attemptPurchaseTry()
        }

        val (text, index) = ConversationManager.getRandomClawMachineWithIndex()
        binding.bubbleText.text = text
        VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, index))
        binding.clawString.pivotY = 0f

        // Setup game logic
        setupClawControls()

        // Initialize prizes after layout
        binding.gameContainer.viewTreeObserver.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                binding.gameContainer.viewTreeObserver.removeOnGlobalLayoutListener(this)
                if (binding.gameContainer.width > 0 && binding.gameContainer.height > 0) {
                    randomizePrizes()
                }
            }
        })

        // Timer updates are started in onResume()
    }

    // ==================== Tries System ====================

    private fun loadStatistics() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        totalPlays = prefs.getInt(KEY_TOTAL_PLAYS, 0)
        totalWins = prefs.getInt(KEY_TOTAL_WINS, 0)
        totalEarnings = prefs.getInt(KEY_TOTAL_EARNINGS, 0)
        highestSingleWin = prefs.getInt(KEY_HIGHEST_WIN, 0)
    }

    private fun saveStatistics() {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
            putInt(KEY_TOTAL_PLAYS, totalPlays)
            putInt(KEY_TOTAL_WINS, totalWins)
            putInt(KEY_TOTAL_EARNINGS, totalEarnings)
            putInt(KEY_HIGHEST_WIN, highestSingleWin)
            apply()
        }
    }

    private fun vibrateLight() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(30, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(30)
        }
    }

    private fun vibrateMedium() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(50)
        }
    }

    private fun vibrateSuccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val timings = longArrayOf(0, 50, 50, 100)
            val amplitudes = intArrayOf(0, 100, 0, 255)
            vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(150)
        }
    }

    // ==================== Tries System ====================

    private fun loadTriesData() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        remainingTries = prefs.getInt(KEY_TRIES, maxTries)
        nextTryRefreshTime = prefs.getLong(KEY_NEXT_REFRESH, 0L)

        // Check if tries should refresh (FIXED: Now calculates multiple tries)
        val currentTime = System.currentTimeMillis()
        if (nextTryRefreshTime > 0 && currentTime >= nextTryRefreshTime && remainingTries < maxTries) {
            // Calculate how many tries should be added based on elapsed time
            val elapsedMs = currentTime - nextTryRefreshTime
            val triesEarned = min(
                ((elapsedMs / tryRefreshIntervalMs).toInt() + 1),
                maxTries - remainingTries
            )

            remainingTries += triesEarned

            // Update next refresh time
            if (remainingTries < maxTries) {
                nextTryRefreshTime = currentTime + tryRefreshIntervalMs
            } else {
                nextTryRefreshTime = 0L
            }

            saveTriesData()
        }
    }

    private fun saveTriesData() {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
            putInt(KEY_TRIES, remainingTries)
            putLong(KEY_NEXT_REFRESH, nextTryRefreshTime)
            apply()
        }
    }

    private fun consumeTry() {
        if (remainingTries > 0) {
            remainingTries--

            // Schedule next try refresh if not at max
            if (remainingTries < maxTries && nextTryRefreshTime == 0L) {
                nextTryRefreshTime = System.currentTimeMillis() + tryRefreshIntervalMs
            }

            saveTriesData()
            updateTriesDisplay()
        }
    }

    private fun addTry() {
        if (remainingTries < maxTries) {
            remainingTries++

            // Schedule next refresh if still not at max
            if (remainingTries < maxTries) {
                nextTryRefreshTime = System.currentTimeMillis() + tryRefreshIntervalMs
            } else {
                nextTryRefreshTime = 0L
            }

            saveTriesData()
            updateTriesDisplay()
        }
    }

    // ==================== Purchase System ====================

    private fun getCurrentDateString(): String {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return dateFormat.format(Date())
    }

    private fun loadPurchaseData() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        lastPurchaseDate = prefs.getString(KEY_LAST_PURCHASE_DATE, "") ?: ""
        dailyPurchasesRemaining = prefs.getInt(KEY_DAILY_PURCHASES, maxDailyPurchases)

        // Check if day has changed - reset daily purchases
        val currentDate = getCurrentDateString()
        if (lastPurchaseDate != currentDate) {
            dailyPurchasesRemaining = maxDailyPurchases
            lastPurchaseDate = currentDate
            savePurchaseData()
        }
    }

    private fun savePurchaseData() {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
            putInt(KEY_DAILY_PURCHASES, dailyPurchasesRemaining)
            putString(KEY_LAST_PURCHASE_DATE, lastPurchaseDate)
            apply()
        }
    }

    private fun updatePurchaseDisplay() {
        binding.buyTriesRemaining.text = "$dailyPurchasesRemaining/$maxDailyPurchases"

        // Check if user can still purchase
        lifecycleScope.launch {
            val currentCurrency = userRepository.getCurrency()
            val canPurchase = dailyPurchasesRemaining > 0 && currentCurrency >= tryCost

            binding.buyTriesButton.alpha = if (canPurchase) 1.0f else 0.5f
            binding.buyTriesButton.isEnabled = canPurchase
        }
    }

    private fun attemptPurchaseTry() {
        if (dailyPurchasesRemaining <= 0) {
            binding.bubbleText.text = "You've used all your daily purchases! Come back tomorrow~ 🌙"
            return
        }

        lifecycleScope.launch {
            val currentCurrency = userRepository.getCurrency()

            if (currentCurrency < tryCost) {
                binding.bubbleText.text = "Not enough ✷! You need $tryCost ✷ to buy a try~"
                return@launch
            }

            // Deduct currency using spendCurrency
            val success = userRepository.spendCurrency(tryCost)
            if (!success) {
                binding.bubbleText.text = "Couldn't complete purchase. Try again!"
                return@launch
            }
            CacheManager.invalidateCurrencyCache()

            // Add try (beyond max limit for purchased tries)
            remainingTries++
            dailyPurchasesRemaining--
            lastPurchaseDate = getCurrentDateString()

            // Save data
            saveTriesData()
            savePurchaseData()

            // Update UI
            updateTriesDisplay()
            updatePurchaseDisplay()

            // Feedback
            vibrateLight()
            binding.bubbleText.text = "Yay! You got an extra try! 🎯 ($dailyPurchasesRemaining purchases left today)"
        }
    }

    private fun updateTriesDisplay() {
        binding.triesText.text = "$remainingTries/$maxTries"

        // Update button state
        val canPlay = remainingTries > 0 && currentState == GameState.IDLE
        binding.grabButton.isEnabled = canPlay
        binding.grabButton.alpha = if (canPlay) 1.0f else 0.5f
    }

    private fun updateTriesTimer() {
        if (remainingTries >= maxTries) {
            binding.timerText.visibility = View.GONE
            return
        }

        val currentTime = System.currentTimeMillis()
        if (currentTime >= nextTryRefreshTime) {
            // Time to refresh a try
            addTry()
            return
        }

        // Show countdown
        val remainingMs = nextTryRefreshTime - currentTime
        val minutes = (remainingMs / 1000 / 60).toInt()
        val seconds = ((remainingMs / 1000) % 60).toInt()

        binding.timerText.text = String.format(Locale.getDefault(), "Next in %d:%02d", minutes, seconds)
        binding.timerText.visibility = View.VISIBLE
    }

    // ==================== Controls ====================

    @SuppressLint("ClickableViewAccessibility")
    private fun setupClawControls() {
        binding.grabButton.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> onGrabButtonPressed()
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> onGrabButtonReleased()
            }
            true
        }
    }

    private fun onGrabButtonPressed() {
        if (currentState != GameState.IDLE || remainingTries <= 0) return

        vibrateLight() // Haptic feedback
        currentState = GameState.MOVING
        binding.bubbleText.text = ConversationManager.getClawMachineMove()
        VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, ConversationManager.getClawMachineMoveIndex()))
        handler.post(moveRunnable)
    }

    private fun onGrabButtonReleased() {
        if (currentState != GameState.MOVING) return

        vibrateMedium() // Haptic feedback
        handler.removeCallbacks(moveRunnable)
        consumeTry()
        totalPlays++
        saveStatistics()
        startDropSequence()
    }

    // ==================== Claw Movement ====================

    private fun updateClawPosition() {
        val containerWidth = binding.gameContainer.width
        if (containerWidth <= 0) return

        val maxX = containerWidth.toFloat() - binding.clawGroup.width

        // Calculate speed with smooth slowdown near edges
        val edgeDistance = minOf(clawX, maxX - clawX)
        val edgeThreshold = 50f * resources.displayMetrics.density
        val speedMultiplier = if (edgeDistance < edgeThreshold) {
            0.5f + (edgeDistance / edgeThreshold) * 0.5f // Slow down near edges
        } else {
            1f
        }

        clawX += moveSpeed * moveDirection * speedMultiplier

        // Bounce at edges with subtle animation
        when {
            clawX >= maxX -> {
                clawX = maxX
                moveDirection = -1
                // Subtle bounce effect
                animateClawBounce()
            }
            clawX <= 0 -> {
                clawX = 0f
                moveDirection = 1
                // Subtle bounce effect
                animateClawBounce()
            }
        }

        binding.clawGroup.translationX = clawX
    }

    private fun animateClawBounce() {
        // Quick subtle rotation bounce when hitting edge
        ObjectAnimator.ofFloat(binding.claw, "rotation", 0f, 3f * -moveDirection, 0f).apply {
            duration = 150
            interpolator = DecelerateInterpolator()
            start()
        }
    }

    // ==================== Game Sequence ====================

    private fun startDropSequence() {
        currentState = GameState.DROPPING

        val containerHeight = binding.gameContainer.height.toFloat()
        val clawHeight = binding.claw.height.toFloat()
        val dropDistance = containerHeight - clawHeight - (40 * resources.displayMetrics.density)

        animateDrop(dropDistance)
    }

    private fun animateDrop(dropDistance: Float) {
        // First: small anticipation movement (claw goes up slightly before dropping)
        val anticipationDistance = -15f * resources.displayMetrics.density

        val anticipation = ValueAnimator.ofFloat(0f, anticipationDistance).apply {
            duration = 150
            interpolator = DecelerateInterpolator()
            addUpdateListener { animator ->
                val y = animator.animatedValue as Float
                binding.claw.translationY = y
                updateClawString(y)
            }
        }

        // Then: accelerating drop with slight bounce at the end
        val drop = ValueAnimator.ofFloat(anticipationDistance, dropDistance).apply {
            duration = ANIM_DROP_DURATION
            interpolator = AccelerateInterpolator(1.5f)
            addUpdateListener { animator ->
                val y = animator.animatedValue as Float
                binding.claw.translationY = y
                updateClawString(y)
            }
        }

        // Small bounce at bottom
        val bounceUp = ValueAnimator.ofFloat(dropDistance, dropDistance - 20f).apply {
            duration = 100
            interpolator = DecelerateInterpolator()
            addUpdateListener { animator ->
                binding.claw.translationY = animator.animatedValue as Float
            }
        }

        val bounceDown = ValueAnimator.ofFloat(dropDistance - 20f, dropDistance).apply {
            duration = 100
            interpolator = AccelerateInterpolator()
            addUpdateListener { animator ->
                binding.claw.translationY = animator.animatedValue as Float
            }
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    checkPrizeCatch(dropDistance)
                }
            })
        }

        // Chain animations
        AnimatorSet().apply {
            playSequentially(anticipation, drop, bounceUp, bounceDown)
            start()
        }
    }

    private fun checkPrizeCatch(dropDistance: Float) {
        val prizes = listOf(binding.prize1, binding.prize2, binding.prize3, binding.prize4)

        // Calculate claw center X position (translationX is the movement offset)
        val clawCenterX = binding.clawGroup.translationX + (binding.clawGroup.width / 2)

        caughtPrize = prizes.firstOrNull { prize ->
            if (prize.visibility != View.VISIBLE) return@firstOrNull false

            // Prize uses absolute x position
            val prizeCenterX = prize.x + (prize.width / 2)
            abs(clawCenterX - prizeCenterX) < prize.width / CATCH_TOLERANCE
        }

        val success = caughtPrize != null
        if (success) {
            vibrateSuccess() // Success haptic feedback

            // Store initial prize position for animation
            caughtPrize?.let {
                caughtPrizeInitialX = it.x
                caughtPrizeInitialY = it.y

                // Don't snap - keep prize at its current position
                // The lift animation will handle the movement
            }

            val basePrizeValue = prizeValues[caughtPrize] ?: 50
            isPrizeSpecial = specialPrizes.contains(caughtPrize)

            // Apply combo multiplier
            consecutiveWins++
            val finalValue = (basePrizeValue * comboMultiplier).toInt()
            caughtPrizeValue = finalValue

            // Update statistics
            totalWins++
            totalEarnings += finalValue
            if (finalValue > highestSingleWin) {
                highestSingleWin = finalValue
            }
            saveStatistics()

            // Show win dialog animation with reward
            val comboText = if (consecutiveWins > 2) " ${consecutiveWins}x COMBO!" else ""
            val specialText = if (isPrizeSpecial) "★RARE★ " else ""
            val winMessage = "${specialText}You got $finalValue ✷!$comboText"
            showResultDialog(winMessage, true)
            VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, ConversationManager.getClawMachineWinIndex()))
        } else {
            consecutiveWins = 0 // Reset combo on miss
            caughtPrizeValue = 0
            isPrizeSpecial = false

            // Show loss dialog animation
            showResultDialog(ConversationManager.getClawMachineLoss(), false)
            VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, ConversationManager.getClawMachineLossIndex()))
        }

        animateLift(dropDistance, success)
    }

    private fun animateLift(dropDistance: Float, hasWon: Boolean) {
        currentState = GameState.LIFTING

        // Initial grab animation - close the claw (visual feedback)
        val grabDuration = if (hasWon) 300L else 150L

        val liftAnimator = ValueAnimator.ofFloat(dropDistance, 0f).apply {
            duration = ANIM_LIFT_DURATION
            interpolator = DecelerateInterpolator(1.5f)
            startDelay = grabDuration // Wait for grab effect

            addUpdateListener { animator ->
                val clawY = animator.animatedValue as Float

                binding.claw.translationY = clawY
                updateClawString(clawY)

                if (hasWon && caughtPrize != null) {
                    val liftAmount = dropDistance - clawY

                    // Only move Y - prize stays at its X position during lift
                    // X movement happens in animateReturn
                    caughtPrize?.y = (caughtPrizeInitialY - liftAmount).coerceAtLeast(-100f)
                }
            }

            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {

                    if (hasWon) {
                        animateReturn()
                    } else {
                        completeRound()
                    }
                }
            })
        }

        // If won, add a small "grab" pulse effect before lifting
        if (hasWon) {
            val pulseScale = ObjectAnimator.ofFloat(binding.claw, "scaleX", 1f, 1.15f, 1f).apply {
                duration = grabDuration
            }
            val pulseScaleY = ObjectAnimator.ofFloat(binding.claw, "scaleY", 1f, 1.15f, 1f).apply {
                duration = grabDuration
            }

            AnimatorSet().apply {
                playTogether(pulseScale, pulseScaleY)
                start()
            }
        }

        currentAnimator = liftAnimator
        liftAnimator.start()
    }

    private fun animateReturn() {
        currentState = GameState.RETURNING

        val startClawX = binding.clawGroup.translationX
        val prizeWidth = caughtPrize?.width ?: 0
        val startPrizeX = caughtPrize?.x ?: 0f

        // Target: prize centered under claw when claw is at translationX = 0
        val targetPrizeX = (binding.clawGroup.width / 2f) - (prizeWidth / 2f)

        currentAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = ANIM_RETURN_DURATION
            interpolator = DecelerateInterpolator(1.2f)

            addUpdateListener { animator ->
                val progress = animator.animatedFraction

                // Move claw back to start
                val clawTranslationX = startClawX * (1f - progress)
                binding.clawGroup.translationX = clawTranslationX

                // Move prize from its current position to under the drop zone
                caughtPrize?.let {
                    it.x = startPrizeX + (targetPrizeX - startPrizeX) * progress
                }
            }

            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    animateDropInHole()
                }
            })

            start()
        }
    }

    private fun animateDropInHole() {
        caughtPrize?.let { prize ->
            val startY = prize.y

            // Create multiple animations for a more dynamic effect
            val dropAnim = ValueAnimator.ofFloat(startY, startY + 250f).apply {
                duration = ANIM_DROP_HOLE_DURATION
                interpolator = AccelerateInterpolator(2f)
                addUpdateListener { animator ->
                    prize.y = animator.animatedValue as Float
                }
            }

            val fadeAnim = ObjectAnimator.ofFloat(prize, "alpha", 1f, 0f).apply {
                duration = ANIM_DROP_HOLE_DURATION
                interpolator = AccelerateInterpolator()
            }

            val scaleXAnim = ObjectAnimator.ofFloat(prize, "scaleX", 1f, 0.3f).apply {
                duration = ANIM_DROP_HOLE_DURATION
                interpolator = AccelerateInterpolator()
            }

            val scaleYAnim = ObjectAnimator.ofFloat(prize, "scaleY", 1f, 0.3f).apply {
                duration = ANIM_DROP_HOLE_DURATION
                interpolator = AccelerateInterpolator()
            }

            val rotationAnim = ObjectAnimator.ofFloat(prize, "rotation", 0f, 360f).apply {
                duration = ANIM_DROP_HOLE_DURATION
                interpolator = LinearInterpolator()
            }

            AnimatorSet().apply {
                playTogether(dropAnim, fadeAnim, scaleXAnim, scaleYAnim, rotationAnim)
                addListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        prize.visibility = View.INVISIBLE
                        prize.alpha = 1f
                        prize.scaleX = 1f
                        prize.scaleY = 1f
                        prize.rotation = 0f

                        if (caughtPrizeValue > 0) {
                            showFloatingCurrency(caughtPrizeValue, isPrizeSpecial)
                            awardCurrency(caughtPrizeValue)
                        }

                        completeRound()
                    }
                })

                start()
            }
        }
    }

    private fun completeRound() {
        currentState = GameState.COMPLETED
        binding.bubbleText.text = ConversationManager.getClawMachineRepeat()
        VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, ConversationManager.getClawMachineRepeatIndex()))

        handler.postDelayed({
            resetClaw()
            currentState = GameState.IDLE
            updateTriesDisplay()
        }, RESET_DELAY)
    }

    // ==================== Helpers ====================

    private fun updateClawString(clawY: Float) {
        val stringHeight = clawY + (binding.claw.height / 2)
        val containerHeight = binding.gameContainer.height.toFloat()
        binding.clawString.scaleY = (stringHeight / containerHeight).coerceAtLeast(0.01f)
    }

    private fun randomizePrizes() {
        val prizes = listOf(binding.prize1, binding.prize2, binding.prize3, binding.prize4)
        val containerWidth = binding.gameContainer.width.toFloat()
        val containerHeight = binding.gameContainer.height.toFloat()
        val dropZoneWidth = binding.dropZone.width.toFloat()
        val density = resources.displayMetrics.density
        val prizeSize = 60 * density // Match layout 60dp
        val spacing = 16 * density
        val bottomMargin = 10 * density

        // Prize drawable themes (fruits, vegetables, bamboo)
        val normalPrizeDrawables = listOf(
            R.drawable.prize_bamboo,
            R.drawable.prize_carrot,
            R.drawable.prize_apple,
            R.drawable.prize_grape,
            R.drawable.prize_strawberry
        )
        
        // Map drawables to emojis to show inside the circles
        val prizeEmojis = mapOf(
            R.drawable.prize_bamboo to "🎋",
            R.drawable.prize_carrot to "🥕",
            R.drawable.prize_apple to "🍎",
            R.drawable.prize_grape to "🍇",
            R.drawable.prize_strawberry to "🍓",
            R.drawable.prize_golden to "🌟"
        )
        
        val specialPrizeDrawable = R.drawable.prize_golden

        // Clear special prizes tracking
        specialPrizes.clear()

        // Calculate safe play area (after drop zone, with margins)
        val safeStartX = dropZoneWidth + spacing
        val safeEndX = containerWidth - prizeSize - spacing
        val groundY = containerHeight - prizeSize - bottomMargin // Ground level

        // Ensure we have valid bounds (both width and height must be valid)
        if (safeEndX <= safeStartX || containerHeight < prizeSize * 2) {
            // Fallback if container is too small or not measured yet
            return
        }

        // Stacking configuration - create 2 stacks for 4 items (2 items per stack)
        val numStacks = 2
        val stackGap = 4 * density // Small gap between stacked items (no overlap!)
        val stackOffsetY = prizeSize + stackGap // Full prize height + gap

        // Calculate stack center positions - evenly distribute in safe area
        val availableWidth = safeEndX - safeStartX
        val stackWidth = availableWidth / numStacks

        val stackCenters = mutableListOf<Float>()
        for (i in 0 until numStacks) {
            val centerX = safeStartX + (stackWidth * i) + (stackWidth / 2)
            stackCenters.add(centerX)
        }

        // Track stack heights
        val stackHeights = MutableList(numStacks) { 0 }
        val maxStackHeight = 2 // 2 items per stack

        // Shuffle prizes for variety
        val shuffledPrizes = prizes.shuffled()

        // Assign each prize to a stack
        shuffledPrizes.forEachIndexed { index, prize ->
            // Determine which stack to use (alternate between stacks)
            val stackIndex = index % numStacks
            val currentStackLevel = stackHeights[stackIndex]

            // Don't exceed max stack height
            if (currentStackLevel >= maxStackHeight) return@forEachIndexed

            // Calculate center X of the stack
            val stackCenterX = stackCenters[stackIndex]

            // Calculate final X position (center the prize on stack center)
            val prizeX = (stackCenterX - (prizeSize / 2))
                .coerceIn(safeStartX, safeEndX)

            // Calculate Y position based on stack level (items stack upward from ground)
            // No overlap - each level is fully above the previous
            val prizeY = (groundY - (currentStackLevel * stackOffsetY))
                .coerceAtLeast(spacing)

            // Reset any existing translations and set absolute position
            prize.translationX = 0f
            prize.translationY = 0f
            prize.x = prizeX
            prize.y = prizeY
            prize.rotation = 0f
            prize.visibility = View.VISIBLE
            prize.alpha = 1f
            prize.scaleX = 1f
            prize.scaleY = 1f

            // Set elevation based on stack level (higher items have higher elevation)
            prize.elevation = (6 + currentStackLevel * 2) * density

            // Increment stack height
            stackHeights[stackIndex]++

            // Determine if this is a special prize (15% chance)
            val isSpecial = Random.nextFloat() < SPECIAL_PRIZE_CHANCE

            // Assign prize drawable based on type
            val prizeDrawable = if (isSpecial) {
                specialPrizeDrawable
            } else {
                normalPrizeDrawables[Random.nextInt(normalPrizeDrawables.size)]
            }
            prize.setBackgroundResource(prizeDrawable)
            
            // Set the emoji text inside the circle
            (prize as? TextView)?.text = prizeEmojis[prizeDrawable] ?: "🎁"

            // Assign currency value (special prizes are 150-250, normal are 10-100)
            val randomValue = if (isSpecial) {
                specialPrizes.add(prize)
                Random.nextInt(150, 251)
            } else {
                Random.nextInt(10, 101)
            }
            prizeValues[prize] = randomValue


            // Animate special prizes with glow effect
            if (isSpecial) {
                animateSpecialPrize(prize)
            }
        }
    }


    private fun animateSpecialPrize(prize: View) {
        val scaleAnimator = ObjectAnimator.ofFloat(prize, "scaleX", 1f, 1.1f, 1f).apply {
            duration = 1500
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
        }
        val scaleYAnimator = ObjectAnimator.ofFloat(prize, "scaleY", 1f, 1.1f, 1f).apply {
            duration = 1500
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
        }
        scaleAnimator.start()
        scaleYAnimator.start()
    }


    private fun resetClaw() {
        clawX = 0f
        moveDirection = 1
        binding.clawGroup.translationX = 0f
        binding.claw.translationY = 0f
        binding.clawString.scaleY = 0.01f
        caughtPrize = null
        caughtPrizeValue = 0
        val (text, index) = ConversationManager.getRandomClawMachineWithIndex()
        binding.bubbleText.text = text
        VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, index))
    }

    private fun showResultDialog(message: String, isWin: Boolean) {
        val density = resources.displayMetrics.density

        // Create overlay container
        val overlay = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.parseColor("#66000000")) // Semi-transparent background
            alpha = 0f
            elevation = 200 * density
            isClickable = true // Block touches to elements below
        }

        // Create dialog card
        val dialogCard = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
            setBackgroundResource(R.drawable.bamboo_speech_bubble)
            elevation = 210 * density
            setPadding((24 * density).toInt(), (20 * density).toInt(), (24 * density).toInt(), (20 * density).toInt())
        }

        // Create message text
        val messageText = TextView(this).apply {
            text = message
            textSize = if (isWin) 18f else 16f
            setTextColor(if (isWin) Color.parseColor("#4CAF50") else Color.parseColor("#757575"))
            gravity = Gravity.CENTER
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            // Add emoji prefix
            val emoji = if (isWin) "🎉 " else "😢 "
            this.text = "$emoji$message"
        }

        dialogCard.addView(messageText)
        overlay.addView(dialogCard)
        (binding.root as ViewGroup).addView(overlay)

        // Animate overlay fade in
        val fadeIn = ObjectAnimator.ofFloat(overlay, "alpha", 0f, 1f).apply {
            duration = 200
        }

        // Animate dialog pop in
        dialogCard.scaleX = 0.5f
        dialogCard.scaleY = 0.5f
        val scaleX = ObjectAnimator.ofFloat(dialogCard, "scaleX", 0.5f, 1.1f, 1f)
        val scaleY = ObjectAnimator.ofFloat(dialogCard, "scaleY", 0.5f, 1.1f, 1f)

        val popIn = AnimatorSet().apply {
            playTogether(fadeIn, scaleX, scaleY)
            duration = 400
            interpolator = OvershootInterpolator(2f)
        }

        // Auto dismiss after delay
        popIn.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                handler.postDelayed({
                    // Fade out and remove
                    val fadeOut = ObjectAnimator.ofFloat(overlay, "alpha", 1f, 0f).apply {
                        duration = 300
                        addListener(object : AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: Animator) {
                                (binding.root as ViewGroup).removeView(overlay)
                            }
                        })
                    }
                    fadeOut.start()
                }, 1500) // Show for 1.5 seconds
            }
        })

        popIn.start()
    }

    private fun awardCurrency(amount: Int) {
        lifecycleScope.launch {
            userRepository.addCurrency(amount)
            // Invalidate cache so MainActivity shows updated currency
            CacheManager.invalidateCurrencyCache()
        }
    }

    private fun showFloatingCurrency(amount: Int, isSpecial: Boolean) {
        val density = resources.displayMetrics.density

        val floatingText = TextView(this).apply {
            text = "+$amount ✷"
            textSize = if (isSpecial) 28f else 24f
            setTextColor(if (isSpecial) Color.parseColor("#FFD700") else Color.parseColor("#81C784"))
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setShadowLayer(8f, 2f, 2f, Color.parseColor("#33000000"))
            alpha = 0f
            elevation = 100 * density
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
        }

        (binding.root as ViewGroup).addView(floatingText)

        // Pop in animation
        val popIn = AnimatorSet().apply {
            val scaleX = ObjectAnimator.ofFloat(floatingText, "scaleX", 0f, 1.3f, 1f)
            val scaleY = ObjectAnimator.ofFloat(floatingText, "scaleY", 0f, 1.3f, 1f)
            val fadeIn = ObjectAnimator.ofFloat(floatingText, "alpha", 0f, 1f)
            playTogether(scaleX, scaleY, fadeIn)
            duration = 300
            interpolator = OvershootInterpolator(2f)
        }

        // Float up animation
        val floatUp = ObjectAnimator.ofFloat(floatingText, "translationY", 0f, -150f).apply {
            duration = 1200
            interpolator = DecelerateInterpolator(2f)
        }

        // Fade out animation
        val fadeOut = AnimatorSet().apply {
            val alpha = ObjectAnimator.ofFloat(floatingText, "alpha", 1f, 0f)
            val scaleX = ObjectAnimator.ofFloat(floatingText, "scaleX", 1f, 0.8f)
            val scaleY = ObjectAnimator.ofFloat(floatingText, "scaleY", 1f, 0.8f)
            playTogether(alpha, scaleX, scaleY)
            duration = 400
            startDelay = 800
        }

        AnimatorSet().apply {
            playTogether(popIn, floatUp, fadeOut)
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    (binding.root as ViewGroup).removeView(floatingText)
                }
            })
            start()
        }
    }

    private fun cleanupAnimations() {
        currentAnimator?.cancel()
        currentAnimator = null
        movementAnimator?.cancel()
        movementAnimator = null
        MemoryOptimizer.removeCallback(handler, moveRunnable)
        MemoryOptimizer.removeCallback(handler, timerUpdateRunnable)
    }

    // ==================== Lifecycle ====================

    override fun onPause() {
        super.onPause()
        saveTriesData()
        savePurchaseData()
        // Stop timer updates when activity is paused to save resources
        MemoryOptimizer.removeCallback(handler, timerUpdateRunnable)
        VoiceManager.pauseVoice()
    }

    override fun onResume() {
        super.onResume()
        // Reload purchase data in case date changed
        loadPurchaseData()
        updatePurchaseDisplay()
        // Resume timer updates when activity comes back
        handler.post(timerUpdateRunnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        cleanupAnimations()
        MemoryOptimizer.cleanupHandler(handler)
        VoiceManager.stopVoice()
    }

    private fun goBackWithLoading() {
        cleanupAnimations()
        LoadingActivity.startWithTarget(
            this,
            MainActivity::class.java,
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
        finish()
    }
}
