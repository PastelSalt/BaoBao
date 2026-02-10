package com.example.baobao.coreoperations

import android.content.Intent
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.LifecycleCoroutineScope
import com.example.baobao.R
import com.example.baobao.audio.SoundManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.conversation.ConversationNode
import com.example.baobao.conversation.UserOption
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.intervention.InterventionManager
import com.example.baobao.intervention.ResourcesActivity
import com.google.android.material.button.MaterialButton
import kotlinx.coroutines.launch
import org.json.JSONArray

class ConversationController(
    private val activity: AppCompatActivity,
    private val binding: ActivityMainBinding,
    private val lifecycleScope: LifecycleCoroutineScope,
    private val userRepository: UserRepository
) {
    var isConversationMode = false
        private set
    var currentMood: String? = null
        private set
    private var currentNode: ConversationNode? = null
    private val conversationPath = mutableListOf<String>()

    // Callback for when conversation ends and should return to mood selection
    var onConversationEnd: (() -> Unit)? = null

    fun startConversation(mood: String) {
        currentMood = mood
        isConversationMode = true
        conversationPath.clear()

        // Clear any previous conversation choices
        binding.conversationChoicesContainer.removeAllViews()
        binding.conversationChoicesContainer.visibility = View.VISIBLE

        binding.characterImage.setImageResource(CharacterImageManager.getCharacterImageForMood(mood))
        lifecycleScope.launch {
            val userData = userRepository.getUserData()
            if (InterventionManager.shouldTriggerIntervention(userData)) {
                currentMood = "intervention"
                val updatedData = InterventionManager.markInterventionShown(userData)
                userRepository.updateUserData(updatedData)
            }
            val startingNode = ConversationManager.getStartingNode(currentMood!!)
            showConversationNode(startingNode)
        }
    }

    fun showConversationNode(node: ConversationNode) {
        currentNode = node
        conversationPath.add(node.id)
        // Use typewriter animation for text reveal
        binding.conversationText.animateText(node.baobaoLine)
        if (currentMood != null) {
            ConversationManager.playNodeAudio(activity, node.id, currentMood!!)
        }
        animateCharacter()
        showFeatureNudge(node.featureNudge)
        showConversationChoices(node.userOptions)
    }

    fun onUserChoice(nextNodeId: String, moodEffect: Int, onShowResources: () -> Unit, onReturnToMood: () -> Unit) {
        if (nextNodeId == "show_resources_screen") {
            onShowResources()
            return
        }
        if (nextNodeId == "return_to_mood" || ConversationManager.isLoopPoint(nextNodeId)) {
            saveConversationState()
            onReturnToMood()
            return
        }
        val nextNode = ConversationManager.getNodeById(currentMood!!, nextNodeId)
        if (nextNode != null) {
            if (moodEffect != 0) {
                applyMoodEffect(moodEffect)
            }
            showConversationNode(nextNode)
        } else {
            onReturnToMood()
        }
    }

    fun exitConversationMode() {
        isConversationMode = false
        currentMood = null
        currentNode = null
        conversationPath.clear()
        binding.conversationChoicesContainer.visibility = View.GONE
        binding.conversationChoicesContainer.removeAllViews() // Clean up old buttons
        binding.featureNudgeCard.visibility = View.GONE

        // Trigger callback to let MainActivity know conversation ended
        onConversationEnd?.invoke()
    }

    fun showMoodGreeting(mood: String) {
        binding.characterImage.setImageResource(CharacterImageManager.getCharacterImageForMood(mood))
        val greetingText = when (mood.lowercase()) {
            "happy" -> "I'm so happy you're feeling good! What would you like to do today? Maybe hear a joke or just hang out? 😊"
            "okay" -> "Thanks for sharing how you're feeling. I'm here with you! Want to chat, play a game, or just take it easy? 🐼"
            "sad" -> "I'm here for you, friend. It's okay to feel this way. Would you like some comfort, a distraction, or just someone to be with? 💙"
            "anxious" -> "I can sense those worried feelings. Let's take this moment by moment together. Want to try something calming, or talk it out? 🫂"
            "tired" -> "You've been working so hard. Let's find a gentle way to help you feel better. Maybe something relaxing? 🌙"
            else -> "I'm so glad you're here! How can I brighten your day? 🐼"
        }
        // Use typewriter animation for text reveal
        binding.conversationText.animateText(greetingText)
    }

    private fun animateCharacter() {
        binding.characterImage.animate()
            .scaleX(1.1f).scaleY(1.1f).setDuration(150)
            .withEndAction {
                binding.characterImage.animate().scaleX(1.0f).scaleY(1.0f).setDuration(150).start()
            }.start()
    }

    private fun showFeatureNudge(feature: String?) {
        val nudgeText = when (feature) {
            "joke" -> "💡 Want a laugh? Tap here to hear BaoBao's jokes!"
            "claw-machine" -> "💡 Ready for some fun? Try the Claw Machine game!"
            "self-care" -> "💡 Need gentle care? Tap for self-care suggestions!"
            "shop" -> "💡 Curious about customizations? Check out the shop!"
            "affirmation" -> "💡 Need encouragement? Tap for daily affirmations!"
            else -> null
        }
        if (nudgeText != null) {
            binding.featureNudgeText.text = nudgeText
            binding.featureNudgeCard.visibility = View.VISIBLE
        } else {
            binding.featureNudgeCard.visibility = View.GONE
        }
    }

    private fun showConversationChoices(options: List<UserOption>) {
        binding.conversationChoicesContainer.removeAllViews()
        options.forEachIndexed { index, option ->
            val button = MaterialButton(activity)
            button.apply {
                text = option.text
                textSize = 15f
                setTextColor(activity.getColor(R.color.white))
                setPadding(16, 16, 16, 16)
                isAllCaps = false
                cornerRadius = 16
                strokeWidth = 3
                val backgroundRes = when (index % 4) {
                    0 -> R.drawable.bamboo_button_green
                    1 -> R.drawable.bamboo_button_light_green
                    2 -> R.drawable.bamboo_button_tan
                    else -> R.drawable.bamboo_button_pale_green
                }
                setBackgroundResource(backgroundRes)
                backgroundTintList = null
                val layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
                )
                layoutParams.setMargins(0, 0, 0, 12)
                this.layoutParams = layoutParams

                // Add click listener to handle user choice
                setOnClickListener {
                    SoundManager.playClickSound(activity)
                    onUserChoice(
                        nextNodeId = option.nextNodeId,
                        moodEffect = option.moodEffect,
                        onShowResources = {
                            val intent = Intent(activity, ResourcesActivity::class.java)
                            activity.startActivity(intent)
                        },
                        onReturnToMood = {
                            // Properly exit conversation mode and cleanup UI
                            exitConversationMode()
                            // Note: MainActivity will handle showing mood dialog again
                        }
                    )
                }
            }
            binding.conversationChoicesContainer.addView(button)
        }

        // Make sure container is visible
        binding.conversationChoicesContainer.visibility = View.VISIBLE
    }

    private fun saveConversationState() {
        lifecycleScope.launch {
            val userData = userRepository.getUserData()
            val pathJson = JSONArray(conversationPath).toString()
            val updatedData = userData.copy(
                currentMood = currentMood ?: "okay",
                currentConversationPath = pathJson,
                lastConversationNodeId = currentNode?.id ?: ""
            )
            userRepository.updateUserData(updatedData)
        }
    }

    private fun applyMoodEffect(effect: Int) {
        lifecycleScope.launch {
            val userData = userRepository.getUserData()
            val newWeight = (userData.emotionalWeight - effect).coerceIn(0, 10)
            val updatedData = userData.copy(emotionalWeight = newWeight)
            userRepository.updateUserData(updatedData)
        }
        if (effect > 0) {
            binding.characterImage.animate().scaleX(1.15f).scaleY(1.15f).setDuration(200)
                .withEndAction {
                    binding.characterImage.animate().scaleX(1.0f).scaleY(1.0f).setDuration(200).start()
                }.start()
        }
    }
}
