package com.example.baobao.additionals

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.AuthActivity
import com.example.baobao.MainActivity
import com.example.baobao.R
import com.example.baobao.database.SessionManager
import com.example.baobao.optimization.MemoryOptimizer

class SecondSplashActivity : AppCompatActivity() {

    private val handler = Handler(Looper.getMainLooper())
    private var splashImage: ImageView? = null
    private var isNavigating = false

    companion object {
        private const val TAG = "SecondSplashActivity"
        private const val FIRST_IMAGE_DURATION = 1500L
        private const val TOTAL_DURATION = 3000L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            // Create layout
            createLayout()

            // Show baobaotextlogo.png first
            safelySetImage(R.drawable.baobaotextlogo)

            // After 1.5 seconds, show moesoft_nobg.png
            handler.postDelayed({
                if (isActivityValid()) {
                    safelySetImage(R.drawable.moesoft_nobg)
                }
            }, FIRST_IMAGE_DURATION)

            // After 3 seconds total, go to AuthActivity
            handler.postDelayed({
                navigateToAuth()
            }, TOTAL_DURATION)

        } catch (e: Exception) {
            Log.e(TAG, "Error in onCreate: ${e.message}", e)
            // If anything fails, navigate immediately to avoid blank screen
            navigateToAuth()
        }
    }

    private fun createLayout() {
        try {
            // Create FrameLayout programmatically
            val frameLayout = android.widget.FrameLayout(this)
            frameLayout.setBackgroundColor(getColor(android.R.color.white))

            // Create ImageView
            splashImage = ImageView(this).apply {
                layoutParams = android.widget.FrameLayout.LayoutParams(
                    android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
                    android.widget.FrameLayout.LayoutParams.MATCH_PARENT
                ).apply {
                    setMargins(48, 48, 48, 48)
                }
                scaleType = ImageView.ScaleType.FIT_CENTER
                contentDescription = getString(R.string.app_name)
            }

            frameLayout.addView(splashImage)
            setContentView(frameLayout)
        } catch (e: Exception) {
            Log.e(TAG, "Error creating layout: ${e.message}", e)
            throw e
        }
    }

    private fun safelySetImage(resourceId: Int) {
        try {
            splashImage?.setImageResource(resourceId)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting image resource: ${e.message}", e)
        }
    }

    private fun isActivityValid(): Boolean {
        return !isDestroyed && !isFinishing && !isNavigating
    }

    private fun navigateToAuth() {
        if (!isActivityValid()) return

        isNavigating = true
        try {
            // Initialize SessionManager
            SessionManager.init(this)

            // Check if user is already logged in
            val targetActivity = if (SessionManager.isLoggedIn(this)) {
                // User has active session, go directly to MainActivity
                MainActivity::class.java
            } else {
                // No session, go to AuthActivity
                AuthActivity::class.java
            }

            val intent = Intent(this, targetActivity).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            startActivity(intent)
            finish()
        } catch (e: Exception) {
            Log.e(TAG, "Error navigating: ${e.message}", e)
            // Try to finish anyway to prevent stuck state
            finish()
        }
    }

    override fun onPause() {
        super.onPause()
        // If user navigates away, clean up
        MemoryOptimizer.cleanupHandler(handler)
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up all callbacks and resources
        MemoryOptimizer.cleanupHandler(handler)

        // Clear image reference to free memory
        try {
            splashImage?.setImageDrawable(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing image: ${e.message}", e)
        }
        splashImage = null
    }
}

