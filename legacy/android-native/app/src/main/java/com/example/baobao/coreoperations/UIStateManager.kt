package com.example.baobao.coreoperations

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.LifecycleCoroutineScope
import com.example.baobao.R
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.database.UserRepository
import com.example.baobao.optimization.CacheManager
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * Manages UI state and status updates for MainActivity
 * Handles time, date, currency, and claw machine status display
 */
class UIStateManager(
    private val activity: AppCompatActivity,
    private val binding: ActivityMainBinding,
    private val lifecycleScope: LifecycleCoroutineScope,
    private val userRepository: UserRepository
) {

    companion object {
        private const val PREFS_NAME = "BaoBaoPrefs"
        private const val KEY_TRIES = "remaining_tries"
        private const val KEY_NEXT_REFRESH = "next_refresh_time"
        private const val MAX_TRIES = 5
        private const val TRY_REFRESH_INTERVAL_MS = 5 * 60 * 1000L // 5 minutes
    }

    /**
     * Updates the status bar with time, date, currency, and claw machine info
     */
    fun updateStatus(currentMood: String? = null) {
        val now = Date()
        val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault())

        binding.timeText.text = timeFormat.format(now)
        binding.dateText.text = dateFormat.format(now)

        // Update currency display with caching
        val cachedCurrency = CacheManager.getCachedCurrency()
        if (cachedCurrency != null) {
            // Use cached value
            binding.currencyText.text = String.format(Locale.getDefault(), "%,d ✷", cachedCurrency)
        } else {
            // Fetch from database and cache
            lifecycleScope.launch {
                val currency = userRepository.getCurrency()
                CacheManager.cacheCurrency(currency)
                binding.currencyText.text = String.format(Locale.getDefault(), "%,d ✷", currency)
            }
        }

        // Update claw machine attempts
        updateClawMachineStatus()
    }

    private fun updateClawMachineStatus() {
        val prefs = activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        var remainingTries = prefs.getInt(KEY_TRIES, MAX_TRIES)
        val nextRefreshTime = prefs.getLong(KEY_NEXT_REFRESH, 0L)

        // Check if tries should refresh
        val currentTime = System.currentTimeMillis()
        if (currentTime >= nextRefreshTime && remainingTries < MAX_TRIES) {
            remainingTries++
            prefs.edit().apply {
                putInt(KEY_TRIES, remainingTries)
                if (remainingTries < MAX_TRIES) {
                    putLong(KEY_NEXT_REFRESH, currentTime + TRY_REFRESH_INTERVAL_MS)
                } else {
                    putLong(KEY_NEXT_REFRESH, 0L)
                }
                apply()
            }
        }

        // Display attempts
        binding.clawAttemptsText.text = "🎮 $remainingTries/$MAX_TRIES"

        // Display timer if not at max
        if (remainingTries < MAX_TRIES) {
            val remainingMs = nextRefreshTime - currentTime
            if (remainingMs > 0) {
                val minutes = (remainingMs / 1000 / 60).toInt()
                val seconds = ((remainingMs / 1000) % 60).toInt()
                binding.clawTimerText.text = String.format(Locale.getDefault(), "Next: %d:%02d", minutes, seconds)
                binding.clawTimerText.visibility = android.view.View.VISIBLE
            } else {
                binding.clawTimerText.visibility = android.view.View.GONE
            }
        } else {
            binding.clawTimerText.visibility = android.view.View.GONE
        }
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

