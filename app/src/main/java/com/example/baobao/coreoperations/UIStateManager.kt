package com.example.baobao.coreoperations

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.LifecycleCoroutineScope
import com.example.baobao.R
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.database.UserRepository
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * Manages UI state and status updates for MainActivity
 * Handles time, date, and mood status display
 */
class UIStateManager(
    private val activity: AppCompatActivity,
    private val binding: ActivityMainBinding,
    private val lifecycleScope: LifecycleCoroutineScope,
    private val userRepository: UserRepository
) {

    /**
     * Updates the status bar with time, date, and mood
     */
    fun updateStatus(currentMood: String? = null) {
        val now = Date()
        val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault())

        binding.timeText.text = timeFormat.format(now)
        binding.dateText.text = dateFormat.format(now)

        // Show user's actual mood
        if (currentMood != null) {
            showMoodInStatus(currentMood)
        } else {
            // Load user's last saved mood from database
            lifecycleScope.launch {
                val userData = userRepository.getUserData()
                val savedMood = userData.currentMood
                if (savedMood.isNotBlank() && savedMood != "okay") {
                    showMoodInStatus(savedMood)
                } else {
                    showTimeBasedGreeting(now)
                }
            }
        }
    }

    /**
     * Shows mood-specific emoji and text in status bar
     */
    private fun showMoodInStatus(mood: String) {
        val (emoji, moodName) = when (mood.lowercase()) {
            "happy" -> "😊" to "Happy"
            "okay" -> "😐" to "Okay"
            "sad" -> "😢" to "Sad"
            "anxious" -> "😰" to "Anxious"
            "tired" -> "😴" to "Tired"
            "intervention" -> "💙" to "Getting Help"
            else -> "🐼" to "Checking in"
        }
        binding.moodText.text = "$emoji $moodName"
    }

    /**
     * Shows time-based greeting for first-time users
     */
    private fun showTimeBasedGreeting(now: Date) {
        val hour = SimpleDateFormat("HH", Locale.getDefault()).format(now).toInt()
        val (emoji, mood) = when (hour) {
            in 5..11 -> "🌅" to "Morning"
            in 12..17 -> "☀️" to "Afternoon"
            in 18..21 -> "🌙" to "Evening"
            else -> "🌟" to "Night"
        }
        binding.moodText.text = "$emoji $mood"
    }

    /**
     * Gets the BGM resource ID for a given key
     */
    fun getBgmResourceForKey(bgmKey: String): Int {
        return when (bgmKey) {
            "little" -> R.raw.main_bgm_little
            "ordinary" -> R.raw.main_bgm_ordinary_days
            else -> R.raw.main_bgm_kakushigoto
        }
    }
}

