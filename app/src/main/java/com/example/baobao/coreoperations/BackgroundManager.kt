package com.example.baobao.coreoperations

import android.app.Activity
import android.view.View
import androidx.core.content.ContextCompat
import com.example.baobao.R

/**
 * Manages background drawables for the main screen
 */
object BackgroundManager {

    private var currentBackground = "default"

    /**
     * Set the current background
     */
    fun setBackground(backgroundId: String) {
        currentBackground = backgroundId
    }

    /**
     * Get the current background
     */
    fun getCurrentBackground(): String = currentBackground

    /**
     * Get drawable resource ID for a background
     */
    fun getBackgroundDrawable(backgroundId: String): Int {
        return when (backgroundId) {
            "default" -> R.drawable.main_bamboo_background
            "pastel_blue_sky" -> R.drawable.bg_pastel_blue_sky
            else -> R.drawable.main_bamboo_background
        }
    }

    /**
     * Apply background to an activity's content view
     */
    fun applyBackground(activity: Activity, backgroundId: String) {
        val drawable = getBackgroundDrawable(backgroundId)
        // Apply to content view (the root of setContentView)
        activity.findViewById<View>(android.R.id.content)?.setBackgroundResource(drawable)
    }

    /**
     * Apply background to a specific view
     */
    fun applyBackgroundToView(view: View, backgroundId: String) {
        val drawable = getBackgroundDrawable(backgroundId)
        view.setBackgroundResource(drawable)
    }

    /**
     * Get list of available backgrounds
     */
    fun getAvailableBackgrounds(): List<String> {
        return listOf("default", "pastel_blue_sky")
    }

    /**
     * Check if a background is available
     */
    fun isBackgroundAvailable(backgroundId: String): Boolean {
        return backgroundId in getAvailableBackgrounds()
    }
}

