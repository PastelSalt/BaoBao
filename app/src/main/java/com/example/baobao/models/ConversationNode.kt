package com.example.baobao.models

/**
 * Represents a single node in the conversation tree
 */
data class ConversationNode(
    val id: String,
    val mood: String, // Which mood pool this belongs to
    val baobaoLine: String,
    val userOptions: List<UserOption>,
    val isLoopPoint: Boolean = false, // Returns to mood selector
    val featureNudge: String? = null // Optional: 'joke', 'claw-machine', 'shop', etc.
)

data class UserOption(
    val text: String,
    val nextNodeId: String,
    val moodEffect: Int = 0 // Positive = mood lift, Negative = mood drop
)
