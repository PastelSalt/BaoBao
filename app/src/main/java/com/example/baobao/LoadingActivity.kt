package com.example.baobao

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.OvershootInterpolator
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.databinding.ActivityLoadingBinding

class LoadingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoadingBinding
    private val handler = Handler(Looper.getMainLooper())
    private var dotAnimationRunnable: Runnable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityLoadingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Start animations
        startCardAnimation()
        startImagePulseAnimation()
        startDotAnimation()

        val targetActivityName = intent.getStringExtra("TARGET_ACTIVITY")
        val delay = intent.getLongExtra("DELAY", 750L)
        val flags = intent.getIntExtra("FLAGS", 0)

        Handler(Looper.getMainLooper()).postDelayed({
            if (targetActivityName != null) {
                try {
                    val targetClass = Class.forName(targetActivityName)
                    val intent = Intent(this, targetClass)
                    if (flags != 0) {
                        intent.flags = flags
                    }
                    startActivity(intent)
                } catch (e: ClassNotFoundException) {
                    e.printStackTrace()
                }
            }
            finish()
        }, delay)
    }

    private fun startCardAnimation() {
        binding.loadingCard.alpha = 0f
        binding.loadingCard.scaleX = 0.8f
        binding.loadingCard.scaleY = 0.8f

        binding.loadingCard.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(500)
            .setInterpolator(OvershootInterpolator(1.2f))
            .start()
    }

    private fun startImagePulseAnimation() {
        val scaleUpX = ObjectAnimator.ofFloat(binding.loadingImage, View.SCALE_X, 1f, 1.08f)
        val scaleUpY = ObjectAnimator.ofFloat(binding.loadingImage, View.SCALE_Y, 1f, 1.08f)
        val scaleDownX = ObjectAnimator.ofFloat(binding.loadingImage, View.SCALE_X, 1.08f, 1f)
        val scaleDownY = ObjectAnimator.ofFloat(binding.loadingImage, View.SCALE_Y, 1.08f, 1f)

        scaleUpX.duration = 800
        scaleUpY.duration = 800
        scaleDownX.duration = 800
        scaleDownY.duration = 800

        val pulseUp = AnimatorSet().apply {
            playTogether(scaleUpX, scaleUpY)
            interpolator = AccelerateDecelerateInterpolator()
        }

        val pulseDown = AnimatorSet().apply {
            playTogether(scaleDownX, scaleDownY)
            interpolator = AccelerateDecelerateInterpolator()
        }

        val pulseAnimation = AnimatorSet().apply {
            playSequentially(pulseUp, pulseDown)
        }

        pulseAnimation.addListener(object : android.animation.AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: android.animation.Animator) {
                if (!isFinishing) {
                    pulseAnimation.start()
                }
            }
        })

        pulseAnimation.start()
    }

    private fun startDotAnimation() {
        val dots = listOf(binding.dot1, binding.dot2, binding.dot3)
        var currentDot = 0

        dotAnimationRunnable = object : Runnable {
            override fun run() {
                dots.forEachIndexed { index, dot ->
                    val scale = if (index == currentDot) 1.4f else 1f
                    val alpha = if (index == currentDot) 1f else 0.4f

                    dot.animate()
                        .scaleX(scale)
                        .scaleY(scale)
                        .alpha(alpha)
                        .setDuration(200)
                        .setInterpolator(AccelerateDecelerateInterpolator())
                        .start()
                }

                currentDot = (currentDot + 1) % dots.size
                handler.postDelayed(this, 400)
            }
        }

        handler.post(dotAnimationRunnable!!)
    }

    override fun onDestroy() {
        super.onDestroy()
        dotAnimationRunnable?.let { handler.removeCallbacks(it) }
    }

    companion object {
        fun startWithTarget(
            activity: AppCompatActivity, 
            targetClass: Class<*>, 
            delay: Long = 750L,
            flags: Int = 0
        ) {
            val intent = Intent(activity, LoadingActivity::class.java).apply {
                putExtra("TARGET_ACTIVITY", targetClass.name)
                putExtra("DELAY", delay)
                putExtra("FLAGS", flags)
            }
            activity.startActivity(intent)
        }
    }
}