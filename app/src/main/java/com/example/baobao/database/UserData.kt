package com.example.baobao.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_data")
data class UserData(
    @PrimaryKey val userId: Int = 1, // Single user app
    val currency: Int = 1000,
    val purchasedBgm: String = "", // Comma-separated list of purchased BGM IDs
    val purchasedThemes: String = "", // Comma-separated list of purchased theme IDs
    val selectedBgm: String = "kakushigoto", // Currently selected BGM
    val selectedTheme: String = "default", // Currently selected theme

    // Mood tracking
    val currentMood: String = "okay", // Current mood selection
    val moodHistory: String = "", // JSON array of mood entries
    val emotionalWeight: Int = 0, // Cumulative emotional weight (0 to 10)
    val consecutiveNegativeCycles: Int = 0, // Track negative mood loops
    val interventionTriggered: Boolean = false, // Has professional help been suggested
    val lastInterventionTime: Long = 0L, // Timestamp of last intervention for cooldown

    // Conversation state
    val currentConversationPath: String = "", // JSON array of node IDs
    val lastConversationNodeId: String = "" // Last visited node
)
