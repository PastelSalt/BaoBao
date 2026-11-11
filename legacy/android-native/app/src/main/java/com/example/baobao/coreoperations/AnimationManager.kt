package com.example.baobao.coreoperations

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.animation.ValueAnimator
import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AccelerateInterpolator
import android.view.animation.AnticipateInterpolator
import android.view.animation.AnticipateOvershootInterpolator
import android.view.animation.BounceInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import android.view.animation.OvershootInterpolator
import androidx.core.view.isVisible
import com.example.baobao.R

/**
 * Comprehensive animation manager for BaoBao app
 * Provides reusable animations for all UI elements
 */
object AnimationManager {

    // Duration constants
    private const val DURATION_INSTANT = 150L
    private const val DURATION_FAST = 250L
    private const val DURATION_NORMAL = 350L
    private const val DURATION_SLOW = 500L
    private const val DURATION_EXTRA_SLOW = 800L

    // ============================================
    // ACTIVITY TRANSITIONS
    // ============================================

    /**
     * Apply slide-in-right / slide-out-left transition (forward navigation)
     */
    fun applySlideTransition(activity: Activity) {
        activity.overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left)
    }

    /**
     * Apply slide-in-left / slide-out-right transition (back navigation)
     */
    fun applySlideBackTransition(activity: Activity) {
        activity.overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right)
    }

    /**
     * Apply slide-up transition (modal-style)
     */
    fun applySlideUpTransition(activity: Activity) {
        activity.overridePendingTransition(R.anim.slide_in_up, R.anim.fade_out)
    }

    /**
     * Apply slide-down transition (dismiss modal)
     */
    fun applySlideDownTransition(activity: Activity) {
        activity.overridePendingTransition(R.anim.fade_in, R.anim.slide_out_down)
    }

    /**
     * Apply pop/zoom transition
     */
    fun applyPopTransition(activity: Activity) {
        activity.overridePendingTransition(R.anim.pop_in, R.anim.fade_out)
    }

    /**
     * Apply fade transition
     */
    fun applyFadeTransition(activity: Activity) {
        activity.overridePendingTransition(R.anim.fade_in, R.anim.fade_out)
    }

    // ============================================
    // VIEW ENTRANCE ANIMATIONS
    // ============================================

    /**
     * Fade in a view
     */
    fun fadeIn(view: View, duration: Long = DURATION_NORMAL, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.visibility = View.VISIBLE
        view.animate()
            .alpha(1f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Fade out a view
     */
    fun fadeOut(view: View, duration: Long = DURATION_FAST, delay: Long = 0, hideAfter: Boolean = true, onEnd: (() -> Unit)? = null) {
        view.animate()
            .alpha(0f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                if (hideAfter) view.visibility = View.GONE
                onEnd?.invoke()
            }
            .start()
    }

    /**
     * Scale and fade in (pop effect)
     */
    fun popIn(view: View, duration: Long = DURATION_NORMAL, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.scaleX = 0.5f
        view.scaleY = 0.5f
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(OvershootInterpolator(1.5f))
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Scale and fade out
     */
    fun popOut(view: View, duration: Long = DURATION_FAST, delay: Long = 0, hideAfter: Boolean = true, onEnd: (() -> Unit)? = null) {
        view.animate()
            .alpha(0f)
            .scaleX(0.5f)
            .scaleY(0.5f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                if (hideAfter) view.visibility = View.GONE
                view.scaleX = 1f
                view.scaleY = 1f
                onEnd?.invoke()
            }
            .start()
    }

    /**
     * Bounce in animation
     */
    fun bounceIn(view: View, duration: Long = DURATION_SLOW, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.scaleX = 0.3f
        view.scaleY = 0.3f
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(BounceInterpolator())
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Slide in from right
     */
    fun slideInRight(view: View, duration: Long = DURATION_NORMAL, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.translationX = view.width.toFloat().takeIf { it > 0 } ?: 300f
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .translationX(0f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Slide in from left
     */
    fun slideInLeft(view: View, duration: Long = DURATION_NORMAL, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.translationX = -(view.width.toFloat().takeIf { it > 0 } ?: 300f)
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .translationX(0f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Slide in from bottom
     */
    fun slideInUp(view: View, duration: Long = DURATION_NORMAL, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.translationY = view.height.toFloat().takeIf { it > 0 } ?: 200f
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .translationY(0f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Slide in from top
     */
    fun slideInDown(view: View, duration: Long = DURATION_NORMAL, delay: Long = 0, onEnd: (() -> Unit)? = null) {
        view.alpha = 0f
        view.translationY = -(view.height.toFloat().takeIf { it > 0 } ?: 200f)
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .translationY(0f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction { onEnd?.invoke() }
            .start()
    }

    /**
     * Slide out to right
     */
    fun slideOutRight(view: View, duration: Long = DURATION_FAST, delay: Long = 0, hideAfter: Boolean = true, onEnd: (() -> Unit)? = null) {
        view.animate()
            .alpha(0f)
            .translationX(view.width.toFloat().takeIf { it > 0 } ?: 300f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                if (hideAfter) view.visibility = View.GONE
                view.translationX = 0f
                view.alpha = 1f
                onEnd?.invoke()
            }
            .start()
    }

    /**
     * Slide out to left
     */
    fun slideOutLeft(view: View, duration: Long = DURATION_FAST, delay: Long = 0, hideAfter: Boolean = true, onEnd: (() -> Unit)? = null) {
        view.animate()
            .alpha(0f)
            .translationX(-(view.width.toFloat().takeIf { it > 0 } ?: 300f))
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                if (hideAfter) view.visibility = View.GONE
                view.translationX = 0f
                view.alpha = 1f
                onEnd?.invoke()
            }
            .start()
    }

    /**
     * Slide out to bottom
     */
    fun slideOutDown(view: View, duration: Long = DURATION_FAST, delay: Long = 0, hideAfter: Boolean = true, onEnd: (() -> Unit)? = null) {
        view.animate()
            .alpha(0f)
            .translationY(view.height.toFloat().takeIf { it > 0 } ?: 200f)
            .setDuration(duration)
            .setStartDelay(delay)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                if (hideAfter) view.visibility = View.GONE
                view.translationY = 0f
                view.alpha = 1f
                onEnd?.invoke()
            }
            .start()
    }

    // ============================================
    // CONTINUOUS ANIMATIONS
    // ============================================

    /**
     * Start a floating/breathing animation
     */
    fun startFloatingAnimation(view: View): ObjectAnimator {
        val animator = ObjectAnimator.ofFloat(view, "translationY", 0f, -20f, 0f)
        animator.duration = 2500
        animator.repeatCount = ValueAnimator.INFINITE
        animator.interpolator = AccelerateDecelerateInterpolator()
        animator.start()
        return animator
    }

    /**
     * Start a gentle pulse animation
     */
    fun startPulseAnimation(view: View, scaleFactor: Float = 1.05f): AnimatorSet {
        val scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1f, scaleFactor, 1f)
        val scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1f, scaleFactor, 1f)

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(scaleX, scaleY)
        animatorSet.duration = 1500
        animatorSet.interpolator = AccelerateDecelerateInterpolator()

        animatorSet.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                if (view.isAttachedToWindow) {
                    animatorSet.start()
                }
            }
        })
        animatorSet.start()
        return animatorSet
    }

    /**
     * Start a gentle sway/rotation animation
     */
    fun startSwayAnimation(view: View, degrees: Float = 3f): ObjectAnimator {
        val animator = ObjectAnimator.ofFloat(view, "rotation", -degrees, degrees)
        animator.duration = 2000
        animator.repeatCount = ValueAnimator.INFINITE
        animator.repeatMode = ValueAnimator.REVERSE
        animator.interpolator = AccelerateDecelerateInterpolator()
        animator.start()
        return animator
    }

    /**
     * Start a shimmer/glow animation
     */
    fun startShimmerAnimation(view: View): ObjectAnimator {
        val animator = ObjectAnimator.ofFloat(view, "alpha", 0.7f, 1f, 0.7f)
        animator.duration = 1500
        animator.repeatCount = ValueAnimator.INFINITE
        animator.interpolator = LinearInterpolator()
        animator.start()
        return animator
    }

    // ============================================
    // INTERACTION ANIMATIONS
    // ============================================

    /**
     * Button press effect (scale down and back)
     */
    fun buttonPressEffect(view: View, onComplete: (() -> Unit)? = null) {
        view.animate()
            .scaleX(0.92f)
            .scaleY(0.92f)
            .setDuration(80)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction {
                view.animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(120)
                    .setInterpolator(OvershootInterpolator(2f))
                    .withEndAction { onComplete?.invoke() }
                    .start()
            }
            .start()
    }

    /**
     * Card tap effect
     */
    fun cardTapEffect(view: View, onComplete: (() -> Unit)? = null) {
        view.animate()
            .scaleX(0.97f)
            .scaleY(0.97f)
            .setDuration(100)
            .setInterpolator(DecelerateInterpolator())
            .withEndAction {
                view.animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(150)
                    .setInterpolator(OvershootInterpolator(1.5f))
                    .withEndAction { onComplete?.invoke() }
                    .start()
            }
            .start()
    }

    /**
     * Shake animation for errors or attention
     */
    fun shake(view: View, intensity: Float = 10f, duration: Long = 400) {
        val animator = ObjectAnimator.ofFloat(
            view, "translationX",
            0f, intensity, -intensity, intensity, -intensity, intensity / 2, -intensity / 2, 0f
        )
        animator.duration = duration
        animator.interpolator = LinearInterpolator()
        animator.start()
    }

    /**
     * Wiggle animation for attention
     */
    fun wiggle(view: View) {
        val rotation = ObjectAnimator.ofFloat(view, "rotation", 0f, -5f, 5f, -5f, 5f, 0f)
        rotation.duration = 500
        rotation.interpolator = LinearInterpolator()
        rotation.start()
    }

    /**
     * Attention pulse (for notifications, hints)
     */
    fun attentionPulse(view: View, count: Int = 3) {
        val scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1f, 1.15f, 1f)
        val scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1f, 1.15f, 1f)

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(scaleX, scaleY)
        animatorSet.duration = 400
        animatorSet.interpolator = AccelerateDecelerateInterpolator()

        var currentCount = 0
        animatorSet.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                currentCount++
                if (currentCount < count) {
                    animatorSet.startDelay = 200
                    animatorSet.start()
                }
            }
        })
        animatorSet.start()
    }

    // ============================================
    // CHARACTER ANIMATIONS
    // ============================================

    /**
     * Character entrance animation (appear with bounce)
     */
    fun characterEntrance(view: View, duration: Long = DURATION_SLOW) {
        view.alpha = 0f
        view.translationY = 100f
        view.scaleX = 0.8f
        view.scaleY = 0.8f
        view.visibility = View.VISIBLE

        view.animate()
            .alpha(1f)
            .translationY(0f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(duration)
            .setInterpolator(OvershootInterpolator(1.2f))
            .start()
    }

    /**
     * Character idle animation (subtle breathing)
     */
    fun startCharacterIdleAnimation(view: View): AnimatorSet {
        val floatY = ObjectAnimator.ofFloat(view, "translationY", 0f, -8f, 0f)
        floatY.duration = 3000
        floatY.repeatCount = ValueAnimator.INFINITE

        val scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1f, 1.02f, 1f)
        val scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1f, 1.02f, 1f)
        scaleX.duration = 3000
        scaleY.duration = 3000
        scaleX.repeatCount = ValueAnimator.INFINITE
        scaleY.repeatCount = ValueAnimator.INFINITE

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(floatY, scaleX, scaleY)
        animatorSet.interpolator = AccelerateDecelerateInterpolator()
        animatorSet.start()
        return animatorSet
    }

    /**
     * Character tap reaction
     */
    fun characterTapReaction(view: View) {
        val scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1f, 1.08f, 0.95f, 1.03f, 1f)
        val scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1f, 0.92f, 1.05f, 0.97f, 1f)

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(scaleX, scaleY)
        animatorSet.duration = 400
        animatorSet.interpolator = AccelerateDecelerateInterpolator()
        animatorSet.start()
    }

    /**
     * Character emotion change animation
     */
    fun characterEmotionChange(view: View, onMidpoint: () -> Unit) {
        view.animate()
            .scaleX(0.9f)
            .scaleY(0.9f)
            .alpha(0.5f)
            .setDuration(150)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                onMidpoint()
                view.animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .alpha(1f)
                    .setDuration(200)
                    .setInterpolator(OvershootInterpolator(1.5f))
                    .start()
            }
            .start()
    }

    /**
     * Character happy bounce
     */
    fun characterHappyBounce(view: View, bounceCount: Int = 3) {
        val translateY = ObjectAnimator.ofFloat(view, "translationY", 0f, -30f, 0f)
        translateY.duration = 300
        translateY.interpolator = BounceInterpolator()

        var count = 0
        translateY.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                count++
                if (count < bounceCount) {
                    translateY.startDelay = 100
                    translateY.start()
                }
            }
        })
        translateY.start()
    }

    // ============================================
    // DIALOG ANIMATIONS
    // ============================================

    /**
     * Dialog entrance animation
     */
    fun dialogEntrance(dialogView: View) {
        dialogView.alpha = 0f
        dialogView.scaleX = 0.8f
        dialogView.scaleY = 0.8f
        dialogView.translationY = 50f

        dialogView.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .translationY(0f)
            .setDuration(DURATION_NORMAL)
            .setInterpolator(OvershootInterpolator(1.2f))
            .start()
    }

    /**
     * Dialog exit animation
     */
    fun dialogExit(dialogView: View, onEnd: () -> Unit) {
        dialogView.animate()
            .alpha(0f)
            .scaleX(0.9f)
            .scaleY(0.9f)
            .translationY(30f)
            .setDuration(DURATION_FAST)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction { onEnd() }
            .start()
    }

    // ============================================
    // STAGGERED ANIMATIONS
    // ============================================

    /**
     * Animate children with staggered delay (for lists, button groups, etc.)
     */
    fun staggeredFadeIn(container: ViewGroup, delayBetween: Long = 80) {
        for (i in 0 until container.childCount) {
            val child = container.getChildAt(i)
            child.alpha = 0f
            child.translationY = 30f

            child.animate()
                .alpha(1f)
                .translationY(0f)
                .setDuration(DURATION_NORMAL)
                .setStartDelay(i * delayBetween)
                .setInterpolator(DecelerateInterpolator())
                .start()
        }
    }

    /**
     * Animate children with staggered pop-in
     */
    fun staggeredPopIn(container: ViewGroup, delayBetween: Long = 100) {
        for (i in 0 until container.childCount) {
            val child = container.getChildAt(i)
            child.alpha = 0f
            child.scaleX = 0.5f
            child.scaleY = 0.5f

            child.animate()
                .alpha(1f)
                .scaleX(1f)
                .scaleY(1f)
                .setDuration(DURATION_NORMAL)
                .setStartDelay(i * delayBetween)
                .setInterpolator(OvershootInterpolator(1.5f))
                .start()
        }
    }

    /**
     * Animate children sliding in from the side
     */
    fun staggeredSlideIn(container: ViewGroup, fromRight: Boolean = true, delayBetween: Long = 60) {
        val offset = if (fromRight) 100f else -100f
        for (i in 0 until container.childCount) {
            val child = container.getChildAt(i)
            child.alpha = 0f
            child.translationX = offset

            child.animate()
                .alpha(1f)
                .translationX(0f)
                .setDuration(DURATION_NORMAL)
                .setStartDelay(i * delayBetween)
                .setInterpolator(DecelerateInterpolator())
                .start()
        }
    }

    // ============================================
    // CROSSFADE ANIMATIONS
    // ============================================

    /**
     * Crossfade between two views
     */
    fun crossFade(viewOut: View, viewIn: View, duration: Long = DURATION_NORMAL) {
        viewIn.alpha = 0f
        viewIn.visibility = View.VISIBLE

        viewIn.animate()
            .alpha(1f)
            .setDuration(duration)
            .setInterpolator(DecelerateInterpolator())
            .start()

        viewOut.animate()
            .alpha(0f)
            .setDuration(duration)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction { viewOut.visibility = View.GONE }
            .start()
    }

    // ============================================
    // SPECIAL EFFECTS
    // ============================================

    /**
     * Celebration effect (scale up with rotation)
     */
    fun celebrationEffect(view: View) {
        val scaleX = ObjectAnimator.ofFloat(view, "scaleX", 1f, 1.3f, 1f)
        val scaleY = ObjectAnimator.ofFloat(view, "scaleY", 1f, 1.3f, 1f)
        val rotation = ObjectAnimator.ofFloat(view, "rotation", 0f, 15f, -15f, 0f)

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(scaleX, scaleY, rotation)
        animatorSet.duration = 600
        animatorSet.interpolator = OvershootInterpolator(1.5f)
        animatorSet.start()
    }

    /**
     * Flip animation (for card reveals, etc.)
     */
    fun flipHorizontal(view: View, onMidpoint: () -> Unit) {
        view.animate()
            .rotationY(90f)
            .setDuration(200)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                onMidpoint()
                view.rotationY = -90f
                view.animate()
                    .rotationY(0f)
                    .setDuration(200)
                    .setInterpolator(DecelerateInterpolator())
                    .start()
            }
            .start()
    }

    /**
     * Ripple expand effect
     */
    fun rippleExpand(view: View) {
        val initialScale = view.scaleX
        view.animate()
            .scaleX(initialScale * 1.5f)
            .scaleY(initialScale * 1.5f)
            .alpha(0f)
            .setDuration(DURATION_NORMAL)
            .setInterpolator(AccelerateInterpolator())
            .withEndAction {
                view.scaleX = initialScale
                view.scaleY = initialScale
                view.alpha = 1f
            }
            .start()
    }

    // ============================================
    // UTILITY FUNCTIONS
    // ============================================

    /**
     * Cancel all animations on a view
     */
    fun cancelAnimations(view: View) {
        view.animate().cancel()
        view.clearAnimation()
    }

    /**
     * Reset view to default state
     */
    fun resetView(view: View) {
        view.alpha = 1f
        view.scaleX = 1f
        view.scaleY = 1f
        view.translationX = 0f
        view.translationY = 0f
        view.rotation = 0f
        view.rotationX = 0f
        view.rotationY = 0f
    }
}

