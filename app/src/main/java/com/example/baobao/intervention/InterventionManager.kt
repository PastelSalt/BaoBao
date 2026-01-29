package com.example.baobao.intervention

import com.example.baobao.database.UserData
import org.json.JSONArray

/**
 * Emotional Intelligence & Care Logic
 * Monitors user's emotional state and triggers professional support when needed
 */
object InterventionManager {

    // Thresholds
    private const val EMOTIONAL_WEIGHT_THRESHOLD = 4
    private const val CONSECUTIVE_NEGATIVE_THRESHOLD = 2

    // Intervention cooldown: 24 hours in milliseconds
    private const val INTERVENTION_COOLDOWN_MS = 24 * 60 * 60 * 1000L

    // Maximum emotional weight cap to prevent runaway accumulation
    private const val MAX_EMOTIONAL_WEIGHT = 10

    /**
     * Check if intervention should be triggered based on emotional weight and patterns
     */
    fun shouldTriggerIntervention(userData: UserData): Boolean {
        // Check cooldown - allow re-triggering after cooldown period even if flag is set
        val cooldownExpired = System.currentTimeMillis() - userData.lastInterventionTime > INTERVENTION_COOLDOWN_MS

        // If intervention was triggered but cooldown expired, we can trigger again
        if (userData.interventionTriggered && !cooldownExpired) {
            return false
        }

        // Check emotional weight threshold
        val weightExceeded = userData.emotionalWeight >= EMOTIONAL_WEIGHT_THRESHOLD

        // Check consecutive negative cycles
        val consecutiveNegative = userData.consecutiveNegativeCycles >= CONSECUTIVE_NEGATIVE_THRESHOLD

        // Also check if user is in a persistent negative pattern
        val inNegativePattern = isInNegativePattern(userData)

        // Trigger if weight exceeded AND (consecutive negative OR negative pattern)
        return weightExceeded && (consecutiveNegative || inNegativePattern)
    }

    /**
     * Get the last N moods from history
     */
    fun getRecentMoods(moodHistory: String, count: Int): List<String> {
        if (moodHistory.isBlank()) return emptyList()

        return try {
            val jsonArray = JSONArray(moodHistory)
            val moods = mutableListOf<String>()

            val startIndex = maxOf(0, jsonArray.length() - count)
            for (i in startIndex until jsonArray.length()) {
                val entry = jsonArray.getJSONObject(i)
                moods.add(entry.getString("mood"))
            }

            moods
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * Check if user is in a negative pattern (used in intervention trigger logic)
     */
    fun isInNegativePattern(userData: UserData): Boolean {
        val recentMoods = getRecentMoods(userData.moodHistory, 3)
        val negativeMoods = listOf("sad", "anxious", "tired")

        return recentMoods.count { it in negativeMoods } >= 2
    }

    /**
     * Mark intervention as shown and record timestamp
     */
    fun markInterventionShown(userData: UserData): UserData {
        return userData.copy(
            interventionTriggered = true,
            lastInterventionTime = System.currentTimeMillis()
        )
    }

    /**
     * Calculate emotional weight change for a mood selection.
     * Call this INSTEAD of manually adding weight in MoodSelectionActivity.
     * Handles both increases (negative moods) and decreases (positive moods).
     */
    fun calculateNewEmotionalWeight(currentWeight: Int, moodName: String): Int {
        val change = when (moodName.lowercase()) {
            "happy" -> -3  // Happy significantly reduces weight
            "okay" -> -2   // Okay moderately reduces weight
            "sad" -> 1     // Sad adds weight
            "anxious" -> 2 // Anxious adds more weight
            "tired" -> 1   // Tired adds weight
            else -> 0
        }

        // Apply change with bounds: 0 to MAX_EMOTIONAL_WEIGHT
        return (currentWeight + change).coerceIn(0, MAX_EMOTIONAL_WEIGHT)
    }

    /**
     * Calculate consecutive negative cycles for a mood selection.
     */
    fun calculateConsecutiveNegativeCycles(currentCycles: Int, moodName: String): Int {
        val negativeMoods = listOf("sad", "anxious", "tired")
        return if (moodName.lowercase() in negativeMoods) {
            currentCycles + 1
        } else {
            0 // Reset on positive mood
        }
    }

    /**
     * Reset intervention flag when user shows improvement.
     * Only resets if user is in a positive mood and has shown sustained improvement.
     */
    fun resetInterventionIfImproved(userData: UserData, currentMood: String): UserData {
        val positiveMoods = listOf("happy", "okay")

        // Only consider resetting on positive moods
        if (currentMood.lowercase() !in positiveMoods) {
            return userData
        }

        // Reset intervention flag if:
        // 1. User selected positive mood AND
        // 2. Emotional weight is now below threshold
        val shouldResetIntervention = userData.emotionalWeight < EMOTIONAL_WEIGHT_THRESHOLD

        return userData.copy(
            interventionTriggered = if (shouldResetIntervention) false else userData.interventionTriggered
            // Note: consecutiveNegativeCycles is already handled in calculateConsecutiveNegativeCycles
        )
    }

    /**
     * Get emotional state summary for debugging/logging
     */
    fun getEmotionalStateSummary(userData: UserData): String {
        return buildString {
            appendLine("Emotional State Summary:")
            appendLine("- Current Mood: ${userData.currentMood}")
            appendLine("- Emotional Weight: ${userData.emotionalWeight}/$MAX_EMOTIONAL_WEIGHT")
            appendLine("- Consecutive Negative: ${userData.consecutiveNegativeCycles}")
            appendLine("- Intervention Shown: ${userData.interventionTriggered}")
            appendLine("- Last Intervention: ${userData.lastInterventionTime}")
            appendLine("- In Negative Pattern: ${isInNegativePattern(userData)}")
            appendLine("- Should Trigger: ${shouldTriggerIntervention(userData)}")
        }
    }
}
