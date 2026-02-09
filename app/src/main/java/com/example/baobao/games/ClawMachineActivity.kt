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
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AccelerateInterpolator
import android.view.animation.BounceInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import android.view.animation.OvershootInterpolator
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
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

    // Prize currency values and labels
    private val prizeValues = mutableMapOf<View, Int>()
    private val prizeLabels = mutableMapOf<View, TextView>()
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

    // Constants
    companion object {
        private const val PREFS_NAME = "BaoBaoPrefs"
        private const val KEY_TRIES = "remaining_tries"
        private const val KEY_NEXT_REFRESH = "next_refresh_time"
        private const val KEY_TOTAL_PLAYS = "claw_total_plays"
        private const val KEY_TOTAL_WINS = "claw_total_wins"
        private const val KEY_TOTAL_EARNINGS = "claw_total_earnings"
        private const val KEY_HIGHEST_WIN = "claw_highest_win"

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
        updateTriesDisplay()

        // Setup UI
        binding.backButton.setOnClickListener {
            SoundManager.playClickSound(this)
            goBackWithLoading()
        }
        val (text, index) = ConversationManager.getRandomClawMachineWithIndex()
        binding.bubbleText.text = text
        VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, index))
        binding.clawString.pivotY = 0f

        // Setup game logic
        setupClawControls()

        // Initialize prizes after layout
        binding.gameContainer.post {
            randomizePrizes()
        }

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
        clawX += moveSpeed * moveDirection

        // Bounce at edges
        when {
            clawX >= maxX -> {
                clawX = maxX
                moveDirection = -1
            }
            clawX <= 0 -> {
                clawX = 0f
                moveDirection = 1
            }
        }

        binding.clawGroup.translationX = clawX
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
        currentAnimator = ValueAnimator.ofFloat(0f, dropDistance).apply {
            duration = ANIM_DROP_DURATION
            interpolator = LinearInterpolator()

            addUpdateListener { animator ->
                val y = animator.animatedValue as Float
                binding.claw.translationY = y
                updateClawString(y)
            }

            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    checkPrizeCatch(dropDistance)
                }
            })

            start()
        }
    }

    private fun checkPrizeCatch(dropDistance: Float) {
        val prizes = listOf(binding.prize1, binding.prize2, binding.prize3, binding.prize4)
        val clawCenterX = binding.clawGroup.translationX + (binding.clawGroup.width / 2)

        caughtPrize = prizes.firstOrNull { prize ->
            if (prize.visibility != View.VISIBLE) return@firstOrNull false

            val prizeCenterX = prize.x + (prize.width / 2)
            abs(clawCenterX - prizeCenterX) < prize.width / CATCH_TOLERANCE
        }

        val success = caughtPrize != null
        if (success) {
            vibrateSuccess() // Success haptic feedback

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

            // Show win message with combo info
            val comboText = if (consecutiveWins > 2) " (${consecutiveWins}x COMBO!)" else ""
            val specialText = if (isPrizeSpecial) " ★RARE★" else ""
            binding.bubbleText.text = "Amazing!$specialText You got $finalValue ✷!$comboText"
            VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, ConversationManager.getClawMachineWinIndex()))

            // Animate prize label
            prizeLabels[caughtPrize]?.let { label ->
                animatePrizeLabelCatch(label)
            }
        } else {
            consecutiveWins = 0 // Reset combo on miss
            caughtPrizeValue = 0
            isPrizeSpecial = false
            binding.bubbleText.text = ConversationManager.getClawMachineLoss()
            VoiceManager.playVoice(this, VoiceManager.getClawMachineAudioId(this, ConversationManager.getClawMachineLossIndex()))
        }

        animateLift(dropDistance, success)
    }

    private fun animateLift(dropDistance: Float, hasWon: Boolean) {
        currentState = GameState.LIFTING

        currentAnimator = ValueAnimator.ofFloat(dropDistance, 0f).apply {
            duration = ANIM_LIFT_DURATION
            interpolator = DecelerateInterpolator()

            addUpdateListener { animator ->
                val y = animator.animatedValue as Float
                binding.claw.translationY = y
                updateClawString(y)

                if (hasWon) {
                    caughtPrize?.translationY = y - dropDistance
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

            start()
        }
    }

    private fun animateReturn() {
        currentState = GameState.RETURNING

        val startX = binding.clawGroup.translationX
        val initialPrizeX = caughtPrize?.translationX ?: 0f

        currentAnimator = ValueAnimator.ofFloat(startX, 0f).apply {
            duration = ANIM_RETURN_DURATION
            interpolator = DecelerateInterpolator()

            addUpdateListener { animator ->
                val x = animator.animatedValue as Float
                binding.clawGroup.translationX = x

                caughtPrize?.let {
                    val deltaX = x - startX
                    it.translationX = initialPrizeX + deltaX
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
            val startY = prize.translationY

            currentAnimator = ValueAnimator.ofFloat(startY, startY + 500f).apply {
                duration = ANIM_DROP_HOLE_DURATION
                interpolator = AccelerateInterpolator()

                addUpdateListener { animator ->
                    prize.translationY = animator.animatedValue as Float
                    prize.alpha = 1f - (animator.animatedFraction * 0.5f) // Fade slightly
                }

                addListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        prize.visibility = View.INVISIBLE
                        prize.alpha = 1f // Reset alpha

                        // Award the currency and show floating text
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
        val prizeSize = 60 * resources.displayMetrics.density // Match layout 60dp
        val spacing = 12 * resources.displayMetrics.density

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

        // Clear old labels
        prizeLabels.values.forEach { label ->
            (label.parent as? ViewGroup)?.removeView(label)
        }
        prizeLabels.clear()
        specialPrizes.clear()

        // Calculate available area for prizes (excluding drop zone)
        val startX = dropZoneWidth + spacing
        val availableWidth = containerWidth - startX - spacing
        val totalPrizesWidth = prizes.size * prizeSize + (prizes.size - 1) * spacing

        val actualSpacing = if (totalPrizesWidth <= availableWidth) {
            (availableWidth - (prizes.size * prizeSize)) / (prizes.size + 1)
        } else {
            spacing * 0.5f
        }

        prizes.forEachIndexed { index, prize ->
            // Position each prize
            val posX = startX + actualSpacing + index * (prizeSize + actualSpacing)
            val randomOffsetX = (Random.nextFloat() - 0.5f) * 20 * resources.displayMetrics.density
            val randomOffsetY = Random.nextFloat() * 10 * resources.displayMetrics.density

            prize.x = (posX + randomOffsetX).coerceIn(startX, containerWidth - prizeSize - spacing)
            prize.y = containerHeight - prizeSize - spacing - randomOffsetY
            prize.translationX = 0f
            prize.translationY = 0f
            prize.visibility = View.VISIBLE
            prize.alpha = 1f
            prize.scaleX = 1f
            prize.scaleY = 1f

            // Determine if this is a special prize (15% chance)
            val isSpecial = Random.nextFloat() < SPECIAL_PRIZE_CHANCE

            // Assign prize drawable based on type
            val prizeDrawable = if (isSpecial) {
                specialPrizeDrawable
            } else {
                normalPrizeDrawables[Random.nextInt(normalPrizeDrawables.size)]
            }
            prize.setBackgroundResource(prizeDrawable)
            
            // Set the emoji text inside the circle (prize is a TextView)
            if (prize is TextView) {
                prize.text = prizeEmojis[prizeDrawable] ?: "🎁"
            }

            // Assign currency value (special prizes are 150-250, normal are 10-100)
            val randomValue = if (isSpecial) {
                specialPrizes.add(prize)
                Random.nextInt(150, 251)
            } else {
                Random.nextInt(10, 101)
            }
            prizeValues[prize] = randomValue

            // Create value label
            val label = createPrizeLabel(randomValue, isSpecial)
            binding.gameContainer.addView(label)
            prizeLabels[prize] = label

            // Position label on top of prize with better visibility
            label.post {
                label.x = prize.x + (prize.width - label.width) / 2
                label.y = prize.y - label.height + 4 * resources.displayMetrics.density
            }

            // Animate special prizes with glow effect
            if (isSpecial) {
                animateSpecialPrize(prize)
            }
        }
    }

    private fun createPrizeLabel(value: Int, isSpecial: Boolean): TextView {
        val density = resources.displayMetrics.density
        return TextView(this).apply {
            text = if (isSpecial) "★$value✷" else "$value✷"
            textSize = if (isSpecial) 13f else 11f
            setTextColor(if (isSpecial) Color.parseColor("#FFD700") else Color.WHITE)
            setPadding((8 * density).toInt(), (4 * density).toInt(), (8 * density).toInt(), (4 * density).toInt())
            background = ContextCompat.getDrawable(
                this@ClawMachineActivity,
                if (isSpecial) R.drawable.bamboo_button_green else R.drawable.bamboo_button_pale_green
            )
            gravity = Gravity.CENTER
            // Use density-scaled elevation to ensure it stays on top of the 6dp prize
            elevation = 10 * density
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            if (isSpecial) {
                setShadowLayer(10f, 0f, 0f, Color.parseColor("#FFD700"))
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

    private fun animatePrizeLabelCatch(label: TextView) {
        val scaleX = ObjectAnimator.ofFloat(label, "scaleX", 1f, 1.5f, 0f).apply {
            duration = 600
        }
        val scaleY = ObjectAnimator.ofFloat(label, "scaleY", 1f, 1.5f, 0f).apply {
            duration = 600
        }
        AnimatorSet().apply {
            playTogether(scaleX, scaleY)
            start()
        }
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

    private fun awardCurrency(amount: Int) {
        lifecycleScope.launch {
            userRepository.addCurrency(amount)
            // Invalidate cache so MainActivity shows updated currency
            CacheManager.invalidateCurrencyCache()
        }
    }

    private fun showFloatingCurrency(amount: Int, isSpecial: Boolean) {
        val floatingText = TextView(this).apply {
            text = "+$amount ✷"
            textSize = if (isSpecial) 26f else 22f
            setTextColor(if (isSpecial) Color.parseColor("#5D4037") else Color.parseColor("#81C784"))
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setShadowLayer(6f, 0f, 0f, Color.parseColor("#FFFFFF"))
            alpha = 0f
            elevation = 20f
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
        }

        (binding.root as ViewGroup).addView(floatingText)

        // Animate: fade in, move up, fade out
        val fadeIn = ObjectAnimator.ofFloat(floatingText, "alpha", 0f, 1f).apply {
            duration = 200
        }
        val moveUp = ObjectAnimator.ofFloat(floatingText, "translationY", 0f, -200f).apply {
            duration = 1500
            interpolator = DecelerateInterpolator()
        }
        val fadeOut = ObjectAnimator.ofFloat(floatingText, "alpha", 1f, 0f).apply {
            duration = 500
            startDelay = 1000
        }
        val scaleX = ObjectAnimator.ofFloat(floatingText, "scaleX", 0.5f, 1.2f, 1f).apply {
            duration = 400
            interpolator = OvershootInterpolator()
        }
        val scaleY = ObjectAnimator.ofFloat(floatingText, "scaleY", 0.5f, 1.2f, 1f).apply {
            duration = 400
            interpolator = OvershootInterpolator()
        }

        AnimatorSet().apply {
            playTogether(fadeIn, moveUp, fadeOut, scaleX, scaleY)
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

        // Clean up prize labels
        prizeLabels.values.forEach { label ->
            (label.parent as? ViewGroup)?.removeView(label)
        }
        prizeLabels.clear()
    }

    // ==================== Lifecycle ====================

    override fun onPause() {
        super.onPause()
        saveTriesData()
        // Stop timer updates when activity is paused to save resources
        MemoryOptimizer.removeCallback(handler, timerUpdateRunnable)
        VoiceManager.pauseVoice()
    }

    override fun onResume() {
        super.onResume()
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
