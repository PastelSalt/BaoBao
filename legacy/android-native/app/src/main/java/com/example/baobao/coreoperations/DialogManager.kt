package com.example.baobao.coreoperations

import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.Toast
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
import com.google.android.material.button.MaterialButton
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
            SoundManager.setVolume(volume)
            prefs.edit().putFloat("bgm_volume", volume).apply()
            dialogBinding.bgmValueText.text = "${value.toInt()}%"
        }

        // SFX slider listener
        dialogBinding.sfxSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            prefs.edit().putFloat("sfx_volume", volume).apply()
            dialogBinding.sfxValueText.text = "${value.toInt()}%"
            // Play test click sound
            SoundManager.playClickSound(activity)
        }

        // Voice slider listener
        dialogBinding.voiceSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            VoiceManager.setVolume(volume)
            prefs.edit().putFloat("voice_volume", volume).apply()
            dialogBinding.voiceValueText.text = "${value.toInt()}%"
        }

        dialogBinding.bubbleText.text = ConversationManager.getRandomSettings()

        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

        dialogBinding.helpButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it) {
                dialog.dismiss()
                com.example.baobao.tutorial.TutorialActivity.start(activity)
            }
        }

        dialogBinding.signOutButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.buttonPressEffect(it) {
                dialog.dismiss()
                lifecycleScope.launch {
                    if (SessionManager.isGuestAccount()) {
                        val userId = SessionManager.getCurrentUserId()
                        try {
                            userRepository.deleteUser(userId)
                        } catch (e: Exception) {
                            android.util.Log.e("DialogManager", "Error deleting guest account: ${e.message}")
                        }
                    }
                    SessionManager.logout(activity)
                    val intent = Intent(activity, AuthActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    activity.startActivity(intent)
                    AnimationManager.applyFadeTransition(activity)
                }
            }
        }

        dialogBinding.closeButton.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                dialog.dismiss()
            }
        }

        dialog.show()

        // Apply entrance animations
        AnimationManager.dialogEntrance(dialogBinding.root)
        AnimationManager.bounceIn(dialogBinding.characterIcon, delay = 200)
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
            val purchasedBgms = userRepository.getPurchasedBgmList()
            val selectedBgm = userRepository.getSelectedBgm()
            val purchasedOutfits = userRepository.getPurchasedOutfitsList()
            val selectedOutfit = userRepository.getSelectedOutfit()
            val purchasedBackgrounds = userRepository.getPurchasedBackgroundsList()
            val selectedBackground = userRepository.getSelectedBackground()

            populateBgmOptions(dialogBinding, dialog, purchasedBgms, selectedBgm)
            populateOutfitOptions(dialogBinding, dialog, purchasedOutfits, selectedOutfit)
            populateBackgroundOptions(dialogBinding, dialog, purchasedBackgrounds, selectedBackground)

            dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

            dialogBinding.closeButton.setOnClickListener {
                SoundManager.playClickSound(activity)
                AnimationManager.cardTapEffect(it) {
                    dialog.dismiss()
                }
            }

            dialogBinding.shopButton.setOnClickListener {
                SoundManager.playClickSound(activity)
                AnimationManager.buttonPressEffect(it) {
                    dialog.dismiss()
                    LoadingActivity.startWithTarget(activity, ShopActivity::class.java)
                }
            }

            dialog.show()

            // Apply entrance animations
            AnimationManager.dialogEntrance(dialogBinding.root)
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

        val allBgms = mutableListOf("kakushigoto")
        allBgms.addAll(purchasedBgms.filter { it != "kakushigoto" })

        if (allBgms.isEmpty()) {
            container.visibility = View.GONE
            noBgmContainer.visibility = View.VISIBLE
            return
        }

        container.visibility = View.VISIBLE
        noBgmContainer.visibility = View.GONE

        val bgmNames = mapOf(
            "kakushigoto" to "Kakushigoto (Default)",
            "little" to "Little",
            "ordinary" to "Ordinary Days"
        )

        for (bgmId in allBgms) {
            val bgmButton = MaterialButton(activity)
            val isSelectedStatus = bgmId == selectedBgm

            bgmButton.apply {
                text = bgmNames[bgmId] ?: bgmId.replaceFirstChar { it.uppercase() }
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply { setMargins(0, 0, 0, 12) }
                
                // Professional programmatic styling
                backgroundTintList = ColorStateList.valueOf(
                    if (isSelectedStatus) activity.getColor(R.color.green) 
                    else activity.getColor(R.color.pale_green)
                )
                setTextColor(
                    if (isSelectedStatus) activity.getColor(R.color.white) 
                    else activity.getColor(R.color.green)
                )
                strokeColor = ColorStateList.valueOf(
                    if (isSelectedStatus) activity.getColor(R.color.white)
                    else activity.getColor(android.R.color.transparent)
                )
                strokeWidth = if (isSelectedStatus) 4 else 0
                
                cornerRadius = 12
                elevation = if (isSelectedStatus) 6f else 2f
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
            container.visibility = View.GONE
            noOutfitContainer.visibility = View.VISIBLE
            return
        }

        container.visibility = View.VISIBLE
        noOutfitContainer.visibility = View.GONE

        val outfitNames = mapOf(
            "outfit1" to "Classic Bao (Default)",
            "outfit2" to "Blue Bao"
        )

        for (outfitId in purchasedOutfits) {
            val outfitButton = MaterialButton(activity)
            val isSelectedStatus = outfitId == selectedOutfit

            outfitButton.apply {
                text = outfitNames[outfitId] ?: outfitId.replaceFirstChar { it.uppercase() }
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply { setMargins(0, 0, 0, 12) }
                
                backgroundTintList = ColorStateList.valueOf(
                    if (isSelectedStatus) activity.getColor(R.color.green) 
                    else activity.getColor(R.color.pale_green)
                )
                setTextColor(
                    if (isSelectedStatus) activity.getColor(R.color.white) 
                    else activity.getColor(R.color.green)
                )
                strokeColor = ColorStateList.valueOf(
                    if (isSelectedStatus) activity.getColor(R.color.white)
                    else activity.getColor(android.R.color.transparent)
                )
                strokeWidth = if (isSelectedStatus) 4 else 0

                cornerRadius = 12
                elevation = if (isSelectedStatus) 6f else 2f
                textSize = 14f
                isAllCaps = false

                setOnClickListener {
                    SoundManager.playClickSound(activity)
                    lifecycleScope.launch {
                        userRepository.setSelectedOutfit(outfitId)
                        CharacterImageManager.setOutfit(outfitId)
                        onCharacterImageUpdate?.invoke()
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
            container.visibility = View.GONE
            noBackgroundContainer.visibility = View.VISIBLE
            return
        }

        container.visibility = View.VISIBLE
        noBackgroundContainer.visibility = View.GONE

        val backgroundNames = mapOf(
            "default" to "Bamboo Forest (Default)",
            "bamboo_clouds" to "Bamboo Clouds",
            "bamboo_plum" to "Bamboo Plum"
        )

        for (backgroundId in purchasedBackgrounds) {
            val backgroundButton = MaterialButton(activity)
            val isSelectedStatus = backgroundId == selectedBackground

            backgroundButton.apply {
                text = backgroundNames[backgroundId] ?: backgroundId.replaceFirstChar { it.uppercase() }
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply { setMargins(0, 0, 0, 12) }
                
                backgroundTintList = ColorStateList.valueOf(
                    if (isSelectedStatus) activity.getColor(R.color.green) 
                    else activity.getColor(R.color.pale_green)
                )
                setTextColor(
                    if (isSelectedStatus) activity.getColor(R.color.white) 
                    else activity.getColor(R.color.green)
                )
                strokeColor = ColorStateList.valueOf(
                    if (isSelectedStatus) activity.getColor(R.color.white)
                    else activity.getColor(android.R.color.transparent)
                )
                strokeWidth = if (isSelectedStatus) 4 else 0

                cornerRadius = 12
                elevation = if (isSelectedStatus) 6f else 2f
                textSize = 14f
                isAllCaps = false

                setOnClickListener {
                    SoundManager.playClickSound(activity)
                    AnimationManager.buttonPressEffect(it)
                    lifecycleScope.launch {
                        userRepository.setSelectedBackground(backgroundId)
                        onBackgroundUpdate?.invoke()
                        Toast.makeText(activity, "Background changed!", Toast.LENGTH_SHORT).show()
                        dialog.dismiss()
                    }
                }
            }
            container.addView(backgroundButton)
        }
    }

    /**
     * Shows the mood selection dialog with animations
     */
    fun showMoodSelectionDialog(onMoodSelected: (PrimaryMood) -> Unit) {
        val dialogBinding = DialogMoodSelectionBinding.inflate(LayoutInflater.from(activity))
        val dialog = AlertDialog.Builder(activity)
            .setView(dialogBinding.root)
            .setCancelable(true)
            .create()

        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

        // Setup mood card click handlers with animations
        dialogBinding.moodHappyCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                dialog.dismiss()
                onMoodSelected(PrimaryMood.HAPPY)
            }
        }
        dialogBinding.moodOkayCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                dialog.dismiss()
                onMoodSelected(PrimaryMood.OKAY)
            }
        }
        dialogBinding.moodSadCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                dialog.dismiss()
                onMoodSelected(PrimaryMood.SAD)
            }
        }
        dialogBinding.moodAnxiousCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                dialog.dismiss()
                onMoodSelected(PrimaryMood.ANXIOUS)
            }
        }
        dialogBinding.moodTiredCard.setOnClickListener {
            SoundManager.playClickSound(activity)
            AnimationManager.cardTapEffect(it) {
                dialog.dismiss()
                onMoodSelected(PrimaryMood.TIRED)
            }
        }

        dialog.show()

        // Apply entrance animations
        AnimationManager.dialogEntrance(dialogBinding.root)

        // Staggered pop-in for mood cards
        val moodCards = listOf(
            dialogBinding.moodHappyCard,
            dialogBinding.moodOkayCard,
            dialogBinding.moodSadCard,
            dialogBinding.moodAnxiousCard,
            dialogBinding.moodTiredCard
        )

        moodCards.forEachIndexed { index, card ->
            AnimationManager.popIn(card, delay = 100L + (index * 80L))
        }
    }
}
