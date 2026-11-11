package com.example.baobao.coreoperations

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatTextView

/**
 * Custom TextView that reveals text character by character like a typewriter
 * Similar to visual novel text reveals
 */
class TypewriterTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : AppCompatTextView(context, attrs, defStyleAttr) {

    private var fullText: CharSequence = ""
    private var currentIndex = 0
    private var charDelay: Long = 35L // Milliseconds between characters
    private val handler = Handler(Looper.getMainLooper())
    private var isAnimating = false
    private var onCompleteListener: (() -> Unit)? = null
    private var isPaused = false

    private val typewriterRunnable = object : Runnable {
        override fun run() {
            if (isPaused) return

            if (currentIndex <= fullText.length) {
                text = fullText.subSequence(0, currentIndex)
                currentIndex++

                // Vary the delay slightly for more natural feel
                val nextDelay = when {
                    currentIndex > 0 && currentIndex <= fullText.length -> {
                        val lastChar = fullText[currentIndex - 1]
                        when (lastChar) {
                            '.', '!', '?' -> charDelay * 4  // Longer pause at sentence end
                            ',', ';', ':' -> charDelay * 2  // Medium pause at clause breaks
                            ' ' -> charDelay / 2            // Faster for spaces
                            else -> charDelay
                        }
                    }
                    else -> charDelay
                }

                handler.postDelayed(this, nextDelay)
            } else {
                isAnimating = false
                onCompleteListener?.invoke()
            }
        }
    }

    /**
     * Start revealing text with typewriter effect
     * @param text The full text to reveal
     * @param delayPerChar Milliseconds between each character (default 35ms)
     * @param onComplete Callback when animation completes
     */
    fun animateText(
        text: CharSequence,
        delayPerChar: Long = 35L,
        onComplete: (() -> Unit)? = null
    ) {
        // Stop any existing animation
        stopAnimation()

        fullText = text
        charDelay = delayPerChar
        currentIndex = 0
        isAnimating = true
        isPaused = false
        onCompleteListener = onComplete

        // Start with empty text
        this.text = ""

        // Begin animation
        handler.post(typewriterRunnable)
    }

    /**
     * Instantly complete the text reveal
     */
    fun skipToEnd() {
        if (isAnimating) {
            handler.removeCallbacks(typewriterRunnable)
            text = fullText
            currentIndex = fullText.length
            isAnimating = false
            onCompleteListener?.invoke()
        }
    }

    /**
     * Stop the animation
     */
    fun stopAnimation() {
        handler.removeCallbacks(typewriterRunnable)
        isAnimating = false
        isPaused = false
    }

    /**
     * Pause the animation
     */
    fun pauseAnimation() {
        isPaused = true
    }

    /**
     * Resume the animation
     */
    fun resumeAnimation() {
        if (isPaused && isAnimating) {
            isPaused = false
            handler.post(typewriterRunnable)
        }
    }

    /**
     * Check if currently animating
     */
    fun isCurrentlyAnimating(): Boolean = isAnimating

    /**
     * Set text instantly without animation
     */
    fun setTextInstant(text: CharSequence) {
        stopAnimation()
        fullText = text
        this.text = text
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopAnimation()
    }
}

