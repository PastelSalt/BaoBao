package com.example.baobao.models

/**
 * User's emotional state and history
 */
data class MoodEntry(
    val mood: String, // "happy", "okay", "sad", "anxious", "tired"
    val timestamp: Long,
    val weight: Int // Emotional weight: Sad=1, Anxious=2, Tired=1, Happy/Okay=0
)

enum class PrimaryMood(val displayName: String, val emoji: String, val weight: Int) {
    HAPPY("Happy/Good", "😊", 0),
    OKAY("Okay/Meh", "😐", 0),
    SAD("Sad/Down", "😢", 1),
    ANXIOUS("Anxious/Worried", "😰", 2),
    TIRED("Tired/Drained", "😴", 1);

    companion object {
        fun fromString(value: String): PrimaryMood {
            return values().find { it.name.equals(value, ignoreCase = true) } ?: OKAY
        }
    }
}
