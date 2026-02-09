package com.example.baobao.coreoperations

import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.LifecycleCoroutineScope
import com.example.baobao.AuthActivity
import com.example.baobao.R
import com.example.baobao.ShopActivity
import com.example.baobao.additionals.LoadingActivity
import com.example.baobao.audio.SoundManager
import com.example.baobao.audio.VoiceManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.database.UserRepository
import com.example.baobao.database.SessionManager
import com.example.baobao.databinding.DialogCustomizeBinding
import com.example.baobao.databinding.DialogMoodSelectionBinding
import com.example.baobao.databinding.DialogSettingsBinding
import com.example.baobao.models.PrimaryMood
import kotlinx.coroutines.launch

/**
 * Manages all dialog-related functionality for MainActivity
 * Handles Settings, Customize, and Mood Selection dialogs
 */
class DialogManager(
    private val activity: AppCompatActivity,
    private val lifecycleScope: LifecycleCoroutineScope,
    private val userRepository: UserRepository,
    private val onCharacterImageUpdate: (() -> Unit)? = null,
    private val onBackgroundUpdate: (() -> Unit)? = null
) {

    /**
     * Shows the settings dialog with volume controls
     */
    fun showSettingsDialog() {
        val dialogBinding = DialogSettingsBinding.inflate(LayoutInflater.from(activity))
        val dialog = AlertDialog.Builder(activity, R.style.CustomDialogTheme)
            .setView(dialogBinding.root)
            .create()

        val prefs = activity.getSharedPreferences("BaoBaoPrefs", Context.MODE_PRIVATE)

        // Load and apply selected outfit to character icon
        lifecycleScope.launch {
            val selectedOutfit = userRepository.getSelectedOutfit()
            CharacterImageManager.setOutfit(selectedOutfit)
            // Update character icon with current outfit
            dialogBinding.characterIcon.setImageResource(
                CharacterImageManager.getCharacterImage(CharacterImageManager.Emotion.HELLO)
            )
        }

        // Load BGM volume
        val currentBgmVolume = prefs.getFloat("bgm_volume", 0.7f)
        dialogBinding.bgmSlider.value = currentBgmVolume * 100f
        dialogBinding.bgmValueText.text = "${(currentBgmVolume * 100).toInt()}%"

        // Load SFX volume
        val currentSfxVolume = prefs.getFloat("sfx_volume", 0.8f)
        dialogBinding.sfxSlider.value = currentSfxVolume * 100f
        dialogBinding.sfxValueText.text = "${(currentSfxVolume * 100).toInt()}%"

        // Load Voice volume
        val currentVoiceVolume = prefs.getFloat("voice_volume", 0.8f)
        dialogBinding.voiceSlider.value = currentVoiceVolume * 100f
        dialogBinding.voiceValueText.text = "${(currentVoiceVolume * 100).toInt()}%"

        // BGM slider listener
        dialogBinding.bgmSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            // Apply to current BGM player immediately
            SoundManager.setVolume(volume)
            // Save to preferences for future use
            prefs.edit().putFloat("bgm_volume", volume).apply()
            // Update display
            dialogBinding.bgmValueText.text = "${value.toInt()}%"
        }

        // SFX slider listener
        dialogBinding.sfxSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            // Save to preferences (SFX reads this when playing)
            prefs.edit().putFloat("sfx_volume", volume).apply()
            // Update display
            dialogBinding.sfxValueText.text = "${value.toInt()}%"
            // Play test click sound to demonstrate volume
            SoundManager.playClickSound(activity)
        }

        // Voice slider listener
        dialogBinding.voiceSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            // Apply to VoiceManager immediately
            VoiceManager.setVolume(volume)
            // Save to preferences for future use
            prefs.edit().putFloat("voice_volume", volume).apply()
            // Update display
            dialogBinding.voiceValueText.text = "${value.toInt()}%"
        }

        dialogBinding.bubbleText.text = ConversationManager.getRandomSettings()

        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

        dialogBinding.signOutButton.setOnClickListener {
            dialog.dismiss()

            // Delete guest account if signing out from guest account
            lifecycleScope.launch {
                if (SessionManager.isGuestAccount()) {
                    val userId = SessionManager.getCurrentUserId()
                    try {
                        userRepository.deleteUser(userId)
                    } catch (e: Exception) {
                        android.util.Log.e("DialogManager", "Error deleting guest account: ${e.message}")
                    }
                }

                // Logout and clear session
                SessionManager.logout(activity)

                // Navigate to AuthActivity
                val intent = Intent(activity, AuthActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                activity.startActivity(intent)
            }
        }

        dialogBinding.closeButton.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    /**
     * Shows the customize dialog with BGM and outfit selection
     */
    fun showCustomizeDialog() {
        val dialogBinding = DialogCustomizeBinding.inflate(LayoutInflater.from(activity))
        val dialog = AlertDialog.Builder(activity, R.style.CustomDialogTheme)
            .setView(dialogBinding.root)
            .create()

        lifecycleScope.launch {
            // Load user's purchased BGMs and outfits
            val purchasedBgms = userRepository.getPurchasedBgmList()
            val selectedBgm = userRepository.getSelectedBgm()
            val purchasedOutfits = userRepository.getPurchasedOutfitsList()
            val selectedOutfit = userRepository.getSelectedOutfit()
            val purchasedBackgrounds = userRepository.getPurchasedBackgroundsList()
            val selectedBackground = userRepository.getSelectedBackground()

            // Populate BGM options
            populateBgmOptions(dialogBinding, dialog, purchasedBgms, selectedBgm)

            // Populate outfit options
            populateOutfitOptions(dialogBinding, dialog, purchasedOutfits, selectedOutfit)

            // Populate background options
            populateBackgroundOptions(dialogBinding, dialog, purchasedBackgrounds, selectedBackground)


            dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

            dialogBinding.closeButton.setOnClickListener {
                SoundManager.playClickSound(activity)
                dialog.dismiss()
            }

            dialogBinding.shopButton.setOnClickListener {
                SoundManager.playClickSound(activity)
                dialog.dismiss()
                LoadingActivity.startWithTarget(activity, ShopActivity::class.java)
            }

            dialog.show()
        }
    }

    private fun populateBgmOptions(
        dialogBinding: DialogCustomizeBinding,
        dialog: AlertDialog,
        purchasedBgms: List<String>,
        selectedBgm: String
    ) {
        val container = dialogBinding.ownedBgmContainer
        val noBgmContainer = dialogBinding.noBgmContainer

        container.removeAllViews()

        // Add default BGM (kakushigoto) - always available
        val allBgms = mutableListOf("kakushigoto")
        allBgms.addAll(purchasedBgms.filter { it != "kakushigoto" })

        if (allBgms.isEmpty()) {
            container.visibility = android.view.View.GONE
            noBgmContainer.visibility = android.view.View.VISIBLE
            return
        }

        container.visibility = android.view.View.VISIBLE
        noBgmContainer.visibility = android.view.View.GONE

        val bgmNames = mapOf(
            "kakushigoto" to "Kakushigoto (Default)",
            "little" to "Little",
            "ordinary" to "Ordinary Days"
        )

        for (bgmId in allBgms) {
            val bgmButton = com.google.android.material.button.MaterialButton(activity)
            val isSelected = bgmId == selectedBgm

            bgmButton.apply {
                text = bgmNames[bgmId] ?: bgmId.replaceFirstChar { it.uppercase() }
                layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, 12)
                }
                setBackgroundColor(if (isSelected) activity.getColor(R.color.green) else activity.getColor(R.color.pale_green))
                setTextColor(if (isSelected) activity.getColor(R.color.white) else activity.getColor(R.color.green))
                cornerRadius = 12
                elevation = if (isSelected) 6f else 2f
                textSize = 14f
                isAllCaps = false

                setOnClickListener {
                    SoundManager.playClickSound(activity)
                    lifecycleScope.launch {
                        userRepository.setSelectedBgm(bgmId)
                        dialog.dismiss()
                    }
                }
            }

            container.addView(bgmButton)
        }
    }

    private fun populateOutfitOptions(
        dialogBinding: DialogCustomizeBinding,
        dialog: AlertDialog,
        purchasedOutfits: List<String>,
        selectedOutfit: String
    ) {
        val container = dialogBinding.ownedOutfitContainer
        val noOutfitContainer = dialogBinding.noOutfitContainer

        container.removeAllViews()

        if (purchasedOutfits.isEmpty()) {
            container.visibility = android.view.View.GONE
            noOutfitContainer.visibility = android.view.View.VISIBLE
            return
        }

        container.visibility = android.view.View.VISIBLE
        noOutfitContainer.visibility = android.view.View.GONE

        val outfitNames = mapOf(
            "outfit1" to "Classic Bao (Default)",
            "outfit2" to "Blue Bao"
        )

        for (outfitId in purchasedOutfits) {
            val outfitButton = com.google.android.material.button.MaterialButton(activity)
            val isSelected = outfitId == selectedOutfit

            outfitButton.apply {
                text = outfitNames[outfitId] ?: outfitId.replaceFirstChar { it.uppercase() }
                layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, 12)
                }
                setBackgroundColor(if (isSelected) activity.getColor(R.color.green) else activity.getColor(R.color.pale_green))
                setTextColor(if (isSelected) activity.getColor(R.color.white) else activity.getColor(R.color.green))
                cornerRadius = 12
                elevation = if (isSelected) 6f else 2f
                textSize = 14f
                isAllCaps = false

                setOnClickListener {
                    SoundManager.playClickSound(activity)
                    lifecycleScope.launch {
                        // Save outfit selection to database
                        userRepository.setSelectedOutfit(outfitId)

                        // Update CharacterImageManager globally
                        CharacterImageManager.setOutfit(outfitId)

                        // Update main screen character image
                        onCharacterImageUpdate?.invoke()


                        // Close dialog
                        dialog.dismiss()
                    }
                }
            }

            container.addView(outfitButton)
        }
    }

    private fun populateBackgroundOptions(
        dialogBinding: DialogCustomizeBinding,
        dialog: AlertDialog,
        purchasedBackgrounds: List<String>,
        selectedBackground: String
    ) {
        val container = dialogBinding.ownedBackgroundContainer
        val noBackgroundContainer = dialogBinding.noBackgroundContainer

        container.removeAllViews()

        if (purchasedBackgrounds.isEmpty()) {
            container.visibility = android.view.View.GONE
            noBackgroundContainer.visibility = android.view.View.VISIBLE
            return
        }

        container.visibility = android.view.View.VISIBLE
        noBackgroundContainer.visibility = android.view.View.GONE

        val backgroundNames = mapOf(
            "default" to "Bamboo Forest (Default)",
            "pastel_blue_sky" to "Blue Sky"
        )

        for (backgroundId in purchasedBackgrounds) {
            val backgroundButton = com.google.android.material.button.MaterialButton(activity)
            val isSelected = backgroundId == selectedBackground

            backgroundButton.apply {
                text = backgroundNames[backgroundId] ?: backgroundId.replaceFirstChar { it.uppercase() }
                layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 0, 0, 12)
                }
                setBackgroundColor(if (isSelected) activity.getColor(R.color.green) else activity.getColor(R.color.pale_green))
                setTextColor(if (isSelected) activity.getColor(R.color.white) else activity.getColor(R.color.green))
                cornerRadius = 12
                elevation = if (isSelected) 6f else 2f
                textSize = 14f
                isAllCaps = false

                setOnClickListener {
                    SoundManager.playClickSound(activity)
                    lifecycleScope.launch {
                        // Save background selection to database
                        userRepository.setSelectedBackground(backgroundId)

                        // Update main screen background immediately
                        onBackgroundUpdate?.invoke()

                        // Show confirmation and close dialog
                        android.widget.Toast.makeText(
                            activity,
                            "Background changed!",
                            android.widget.Toast.LENGTH_SHORT
                        ).show()

                        dialog.dismiss()
                    }
                }
            }

            container.addView(backgroundButton)
        }
    }

    /**
     * Shows the mood selection dialog
     * @param onMoodSelected Callback when a mood is selected
     */
    fun showMoodSelectionDialog(onMoodSelected: (PrimaryMood) -> Unit) {
        val dialogBinding = DialogMoodSelectionBinding.inflate(LayoutInflater.from(activity))

        val dialog = AlertDialog.Builder(activity)
            .setView(dialogBinding.root)
            .setCancelable(true)
            .create()

        // Setup mood card click listeners
        dialogBinding.moodHappyCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            dialog.dismiss()
            onMoodSelected(PrimaryMood.HAPPY)
        }

        dialogBinding.moodOkayCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            dialog.dismiss()
            onMoodSelected(PrimaryMood.OKAY)
        }

        dialogBinding.moodSadCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            dialog.dismiss()
            onMoodSelected(PrimaryMood.SAD)
        }

        dialogBinding.moodAnxiousCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            dialog.dismiss()
            onMoodSelected(PrimaryMood.ANXIOUS)
        }

        dialogBinding.moodTiredCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            dialog.dismiss()
            onMoodSelected(PrimaryMood.TIRED)
        }

        dialog.show()
    }
}
