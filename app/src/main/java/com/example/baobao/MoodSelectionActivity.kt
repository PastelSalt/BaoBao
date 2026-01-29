package com.example.baobao

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityMoodSelectionBinding
import com.example.baobao.intervention.InterventionManager
import com.example.baobao.models.MoodEntry
import com.example.baobao.models.PrimaryMood
import com.google.android.material.card.MaterialCardView
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

class MoodSelectionActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMoodSelectionBinding
    private lateinit var userRepository: UserRepository
    private var selectedMood: PrimaryMood? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMoodSelectionBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val database = AppDatabase.getDatabase(this)
        userRepository = UserRepository(database.userDao())

        setupMoodCards()
        setupContinueButton()

        // Set welcome message
        binding.welcomeText.text = "How are you feeling right now?"
        binding.subtitleText.text = "I'm here for you, whatever you're feeling. Let's talk about it! 🐼"
    }

    private fun setupMoodCards() {
        // Happy card
        binding.moodHappyCard.setOnClickListener {
            selectMood(PrimaryMood.HAPPY, binding.moodHappyCard)
            SoundManager.playClickSound(this)
        }

        // Okay card
        binding.moodOkayCard.setOnClickListener {
            selectMood(PrimaryMood.OKAY, binding.moodOkayCard)
            SoundManager.playClickSound(this)
        }

        // Sad card
        binding.moodSadCard.setOnClickListener {
            selectMood(PrimaryMood.SAD, binding.moodSadCard)
            SoundManager.playClickSound(this)
        }

        // Anxious card
        binding.moodAnxiousCard.setOnClickListener {
            selectMood(PrimaryMood.ANXIOUS, binding.moodAnxiousCard)
            SoundManager.playClickSound(this)
        }

        // Tired card
        binding.moodTiredCard.setOnClickListener {
            selectMood(PrimaryMood.TIRED, binding.moodTiredCard)
            SoundManager.playClickSound(this)
        }
    }

    private fun selectMood(mood: PrimaryMood, selectedCard: MaterialCardView) {
        selectedMood = mood

        // Reset all cards
        resetCardStates()

        // Highlight selected card
        selectedCard.strokeWidth = 8
        selectedCard.cardElevation = 12f

        // Enable continue button
        binding.continueButton.isEnabled = true
        binding.continueButton.alpha = 1f

        // Update response text based on mood
        binding.responseText.text = when (mood) {
            PrimaryMood.HAPPY -> "That's wonderful! I love hearing that! Let's keep those good vibes going! ✨"
            PrimaryMood.OKAY -> "I hear you. Some days are just... okay. And that's perfectly fine! Let's see if we can brighten it up a bit! 🌤️"
            PrimaryMood.SAD -> "I'm here with you, friend. It's okay to feel down sometimes. Let's talk about it together. 💙"
            PrimaryMood.ANXIOUS -> "I understand. Those worried feelings can be tough. Take a deep breath with me—I've got you. 🫂"
            PrimaryMood.TIRED -> "You've been working hard, haven't you? Let's find some gentle ways to help you recharge. 🌙"
        }
    }

    private fun resetCardStates() {
        listOf(
            binding.moodHappyCard,
            binding.moodOkayCard,
            binding.moodSadCard,
            binding.moodAnxiousCard,
            binding.moodTiredCard
        ).forEach { card ->
            card.strokeWidth = 4
            card.cardElevation = 6f
        }
    }

    private fun setupContinueButton() {
        binding.continueButton.isEnabled = false
        binding.continueButton.alpha = 0.5f

        binding.continueButton.setOnClickListener {
            selectedMood?.let { mood ->
                SoundManager.playClickSound(this)
                saveMoodAndContinue(mood)
            }
        }
    }

    private fun saveMoodAndContinue(mood: PrimaryMood) {
        lifecycleScope.launch {
            // Get current user data
            val userData = userRepository.getUserData()

            // Create mood entry
            val moodEntry = MoodEntry(
                mood = mood.name.lowercase(),
                timestamp = System.currentTimeMillis(),
                weight = mood.weight
            )

            // Parse existing mood history
            val moodHistoryArray = if (userData.moodHistory.isNotBlank()) {
                JSONArray(userData.moodHistory)
            } else {
                JSONArray()
            }

            // Add new mood entry
            val moodEntryJson = JSONObject().apply {
                put("mood", moodEntry.mood)
                put("timestamp", moodEntry.timestamp)
                put("weight", moodEntry.weight)
            }
            moodHistoryArray.put(moodEntryJson)

            // Use InterventionManager for proper weight calculation (handles both increase and decrease)
            val newEmotionalWeight = InterventionManager.calculateNewEmotionalWeight(
                userData.emotionalWeight,
                mood.name.lowercase()
            )

            // Use InterventionManager for consecutive negative cycles calculation
            val consecutiveNegative = InterventionManager.calculateConsecutiveNegativeCycles(
                userData.consecutiveNegativeCycles,
                mood.name.lowercase()
            )

            // Update user data with new values
            var updatedUserData = userData.copy(
                currentMood = mood.name.lowercase(),
                moodHistory = moodHistoryArray.toString(),
                emotionalWeight = newEmotionalWeight,
                consecutiveNegativeCycles = consecutiveNegative
            )

            // Check if intervention flag should be reset (user showing improvement)
            updatedUserData = InterventionManager.resetInterventionIfImproved(
                updatedUserData,
                mood.name.lowercase()
            )

            userRepository.updateUserData(updatedUserData)

            // Navigate to main activity with conversation mode
            val intent = Intent(this@MoodSelectionActivity, MainActivity::class.java)
            intent.putExtra("selected_mood", mood.name.lowercase())
            intent.putExtra("start_conversation", true)
            startActivity(intent)
            finish()
        }
    }
}
