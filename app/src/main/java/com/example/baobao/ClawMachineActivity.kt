package com.example.baobao

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import androidx.lifecycle.lifecycleScope
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityClawMachineBinding
import kotlinx.coroutines.launch
import java.util.Locale
import kotlin.math.abs
import kotlin.random.Random

class ClawMachineActivity : BaseActivity() {

    // View Binding
    private lateinit var binding: ActivityClawMachineBinding
    
    // Database
    private lateinit var userRepository: UserRepository

    // Game State
    private enum class GameState {
        IDLE, MOVING, DROPPING, LIFTING, RETURNING, COMPLETED
    }
    private var currentState = GameState.IDLE

    // Claw Movement
    private var clawX = 0f
    private var moveDirection = 1
    private val moveSpeed = 12f

    // Animation
    private var currentAnimator: ValueAnimator? = null
    private var caughtPrize: View? = null
    private var caughtPrizeValue: Int = 0 // Store the currency value of caught prize

    // Prize currency values
    private val prizeValues = mutableMapOf<View, Int>()

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

        private const val ANIM_DROP_DURATION = 1200L
        private const val ANIM_LIFT_DURATION = 1500L
        private const val ANIM_RETURN_DURATION = 1000L
        private const val ANIM_DROP_HOLE_DURATION = 600L
        private const val RESET_DELAY = 2000L
    }

    override fun getBgmResource(): Int = R.raw.clawmachine_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityClawMachineBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize database
        val database = AppDatabase.getDatabase(this)
        userRepository = UserRepository(database.userDao())

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
        binding.bubbleText.text = ConversationManager.getRandomClawMachine()
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

    private fun loadTriesData() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        remainingTries = prefs.getInt(KEY_TRIES, maxTries)
        nextTryRefreshTime = prefs.getLong(KEY_NEXT_REFRESH, 0L)

        // Check if tries should refresh
        val currentTime = System.currentTimeMillis()
        if (currentTime >= nextTryRefreshTime && remainingTries < maxTries) {
            addTry()
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

        currentState = GameState.MOVING
        binding.bubbleText.text = ConversationManager.getClawMachineMove()
        handler.post(moveRunnable)
    }

    private fun onGrabButtonReleased() {
        if (currentState != GameState.MOVING) return

        handler.removeCallbacks(moveRunnable)
        consumeTry()
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
            abs(clawCenterX - prizeCenterX) < prize.width / 1.2
        }

        val success = caughtPrize != null
        if (success) {
            caughtPrizeValue = prizeValues[caughtPrize] ?: 50
            binding.bubbleText.text = "Nice! You got $caughtPrizeValue ✷!"
        } else {
            caughtPrizeValue = 0
            binding.bubbleText.text = ConversationManager.getClawMachineLoss()
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
                }

                addListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        prize.visibility = View.INVISIBLE

                        // Award the random currency value for this prize!
                        if (caughtPrizeValue > 0) {
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
        val dropZoneWidth = binding.dropZone.width.toFloat()
        val startRange = dropZoneWidth + 20
        val endRange = containerWidth - 80
        
        prizes.forEach { prize ->
            prize.x = startRange + Random.nextFloat() * (endRange - startRange - prize.width)
            prize.translationX = 0f
            prize.translationY = 0f
            prize.visibility = View.VISIBLE

            // Assign random currency value from 10 to 100
            val randomValue = Random.nextInt(10, 101)
            prizeValues[prize] = randomValue
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
        binding.bubbleText.text = ConversationManager.getRandomClawMachine()
    }

    private fun awardCurrency(amount: Int) {
        lifecycleScope.launch {
            userRepository.addCurrency(amount)
        }
    }

    private fun cleanupAnimations() {
        currentAnimator?.cancel()
        currentAnimator = null
        handler.removeCallbacks(moveRunnable)
        handler.removeCallbacks(timerUpdateRunnable)
    }

    // ==================== Lifecycle ====================

    override fun onPause() {
        super.onPause()
        saveTriesData()
        // Stop timer updates when activity is paused to save resources
        handler.removeCallbacks(timerUpdateRunnable)
    }

    override fun onResume() {
        super.onResume()
        // Resume timer updates when activity comes back
        handler.post(timerUpdateRunnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        cleanupAnimations()
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