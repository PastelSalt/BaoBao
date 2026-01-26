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
import com.example.baobao.databinding.ActivityClawMachineBinding
import kotlin.math.abs
import kotlin.random.Random

class ClawMachineActivity : BaseActivity() {
    private lateinit var binding: ActivityClawMachineBinding
    
    private var isMoving = false
    private var isAnimatingGrab = false
    private var clawX = 0f
    private var moveDirection = 1 
    private val moveSpeed = 12f
    private val handler = Handler(Looper.getMainLooper())
    
    private var caughtPrize: View? = null

    private val moveRunnable = object : Runnable {
        override fun run() {
            if (isMoving) {
                moveClaw()
                handler.postDelayed(this, 16)
            }
        }
    }

    override fun getBgmResource(): Int = R.raw.clawmachine_bgm

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityClawMachineBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.backButton.setOnClickListener {
            goBackWithLoading()
        }

        binding.bubbleText.text = ConversationManager.getRandomClawMachine()
        binding.clawString.pivotY = 0f
        
        setupClawLogic()
        
        binding.gameContainer.post {
            randomizePrizes()
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun setupClawLogic() {
        binding.grabButton.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    if (!isAnimatingGrab) {
                        isMoving = true
                        binding.bubbleText.text = ConversationManager.getClawMachineMove()
                        handler.post(moveRunnable)
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    if (isMoving) {
                        isMoving = false
                        handler.removeCallbacks(moveRunnable)
                        startGrabAnimation()
                    }
                }
            }
            true
        }
    }

    private fun moveClaw() {
        val containerWidth = binding.gameContainer.width
        if (containerWidth <= 0) return

        val maxWidth = containerWidth.toFloat() - binding.clawGroup.width.toFloat()
        clawX += moveSpeed * moveDirection
        
        if (clawX >= maxWidth) {
            clawX = maxWidth
            moveDirection = -1
        } else if (clawX <= 0) {
            clawX = 0f
            moveDirection = 1
        }
        binding.clawGroup.translationX = clawX
    }

    private fun startGrabAnimation() {
        if (isAnimatingGrab) return
        isAnimatingGrab = true
        
        val containerHeight = binding.gameContainer.height.toFloat()
        val clawHeight = binding.claw.height.toFloat()
        // Drop to just above the floor
        val dropDistance = containerHeight - clawHeight - (40 * resources.displayMetrics.density)
        
        val dropAnimator = ValueAnimator.ofFloat(0f, dropDistance)
        dropAnimator.duration = 1200
        dropAnimator.interpolator = LinearInterpolator()
        
        dropAnimator.addUpdateListener { animator ->
            val value = animator.animatedValue as Float
            binding.claw.translationY = value
            
            // Adjust scale calculation: value is current translationY
            // We want string to stretch from top (0) to claw center
            val stringTargetHeight = value + (binding.claw.height / 2)
            binding.clawString.scaleY = stringTargetHeight / binding.gameContainer.height.toFloat()
        }

        dropAnimator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                checkCatch(dropDistance)
            }
        })
        dropAnimator.start()
    }

    private fun checkCatch(dropDistance: Float) {
        val prizeList = listOf(binding.prize1, binding.prize2, binding.prize3, binding.prize4)
        val clawCenterX = binding.clawGroup.translationX + (binding.clawGroup.width / 2)
        
        caughtPrize = null
        for (prize in prizeList) {
            if (prize.visibility != View.VISIBLE) continue
            
            // Calculate center of prize in gameContainer's coordinates
            val prizeCenterX = prize.x + (prize.width / 2)
            
            if (abs(clawCenterX - prizeCenterX) < prize.width / 1.2) {
                caughtPrize = prize
                break
            }
        }

        if (caughtPrize != null) {
            binding.bubbleText.text = ConversationManager.getClawMachineWin()
            liftClaw(dropDistance, true)
        } else {
            binding.bubbleText.text = ConversationManager.getClawMachineLoss()
            liftClaw(dropDistance, false)
        }
    }

    private fun liftClaw(dropDistance: Float, wasSuccessful: Boolean) {
        val liftAnimator = ValueAnimator.ofFloat(dropDistance, 0f)
        liftAnimator.duration = 1500
        liftAnimator.interpolator = DecelerateInterpolator()
        
        liftAnimator.addUpdateListener { animator ->
            val value = animator.animatedValue as Float
            binding.claw.translationY = value
            
            if (wasSuccessful) {
                caughtPrize?.translationY = value - dropDistance
            }

            val stringTargetHeight = value + (binding.claw.height / 2)
            binding.clawString.scaleY = stringTargetHeight / binding.gameContainer.height.toFloat()
        }

        liftAnimator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                if (wasSuccessful) {
                    moveToDropZone()
                } else {
                    completeGame()
                }
            }
        })
        liftAnimator.start()
    }

    private fun moveToDropZone() {
        val startX = binding.clawGroup.translationX
        val moveBackAnimator = ValueAnimator.ofFloat(startX, 0f)
        moveBackAnimator.duration = 1000
        moveBackAnimator.interpolator = DecelerateInterpolator()
        
        val initialPrizeX = caughtPrize?.translationX ?: 0f

        moveBackAnimator.addUpdateListener { animator ->
            val currentX = animator.animatedValue as Float
            binding.clawGroup.translationX = currentX
            
            caughtPrize?.let {
                val deltaX = currentX - startX
                it.translationX = initialPrizeX + deltaX
            }
        }

        moveBackAnimator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                dropInHole()
            }
        })
        moveBackAnimator.start()
    }

    private fun dropInHole() {
        caughtPrize?.let { prize ->
            val finalDrop = ValueAnimator.ofFloat(prize.translationY, prize.translationY + 500f)
            finalDrop.duration = 600
            finalDrop.interpolator = AccelerateInterpolator()
            finalDrop.addUpdateListener {
                prize.translationY = it.animatedValue as Float
            }
            finalDrop.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    prize.visibility = View.INVISIBLE
                    completeGame()
                }
            })
            finalDrop.start()
        }
    }

    private fun completeGame() {
        binding.bubbleText.text = ConversationManager.getClawMachineRepeat()
        handler.postDelayed({ 
            resetClaw() 
            isAnimatingGrab = false
        }, 2000)
    }

    private fun randomizePrizes() {
        val prizeList = listOf(binding.prize1, binding.prize2, binding.prize3, binding.prize4)
        val containerWidth = binding.gameContainer.width.toFloat()
        val dropZoneWidth = binding.dropZone.width.toFloat()
        val startRange = dropZoneWidth + 20
        val endRange = containerWidth - 80
        
        for (prize in prizeList) {
            val randomX = startRange + Random.nextFloat() * (endRange - startRange - prize.width)
            prize.x = randomX
            prize.translationX = 0f
            prize.translationY = 0f
            prize.visibility = View.VISIBLE
        }
    }

    private fun resetClaw() {
        clawX = 0f
        moveDirection = 1
        binding.clawGroup.translationX = 0f
        binding.claw.translationY = 0f
        binding.clawString.scaleY = 0.01f
        caughtPrize = null
        binding.bubbleText.text = ConversationManager.getRandomClawMachine()
    }

    override fun onBackPressed() {
        goBackWithLoading()
    }

    private fun goBackWithLoading() {
        LoadingActivity.startWithTarget(
            this, 
            MainActivity::class.java, 
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
        finish()
    }
}