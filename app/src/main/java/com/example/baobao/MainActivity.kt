package com.example.baobao

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.lifecycleScope
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.databinding.DialogCustomizeBinding
import com.example.baobao.databinding.DialogSettingsBinding
import com.example.baobao.intervention.InterventionManager
import com.example.baobao.models.ConversationNode
import com.google.android.material.button.MaterialButton
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : BaseActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var userRepository: UserRepository
    private val handler = Handler(Looper.getMainLooper())
    private val timeUpdater = object : Runnable {
        override fun run() {
            updateStatus()
            handler.postDelayed(this, 1000)
        }
    }

    // Conversation state
    private var isConversationMode = false
    private var currentMood: String? = null
    private var currentNode: ConversationNode? = null
    private val conversationPath = mutableListOf<String>()

    // Button toggle state
    private var isShowingStaticButtons = true

    // Return 0 to skip BaseActivity BGM handling - we'll handle it ourselves from database
    override fun getBgmResource(): Int = 0

    private fun getBgmResourceForKey(bgmKey: String): Int {
        return when (bgmKey) {
            "little" -> R.raw.main_bgm_little
            "ordinary" -> R.raw.main_bgm_ordinary_days
            else -> R.raw.main_bgm_kakushigoto
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize database
        val database = AppDatabase.getDatabase(this)
        userRepository = UserRepository(database.userDao())

        // Get selected mood from intent
        val selectedMood = intent.getStringExtra("selected_mood")
        val shouldStartConversation = intent.getBooleanExtra("start_conversation", false)

        setupNavigation()
        setupActionButtons()
        setupCharacterInteraction()
        setupButtonToggle()
        updateStatus()

        // Show toggle button for demo (allows switching to mock conversation choices)
        binding.buttonToggleButton.visibility = View.VISIBLE
        binding.buttonToggleButton.text = "💬 Show Choices"

        // Start conversation mode if mood selected
        if (selectedMood != null && shouldStartConversation) {
            startConversation(selectedMood)
        } else if (selectedMood != null) {
            showMoodGreeting(selectedMood)
        } else {
            binding.conversationText.text = "How can I help you today?"
        }
    }

    private fun showMoodGreeting(mood: String) {
        binding.conversationText.text = when (mood.lowercase()) {
            "happy" -> "I'm so happy you're feeling good! What would you like to do today? Maybe hear a joke or just hang out? 😊"
            "okay" -> "Thanks for sharing how you're feeling. I'm here with you! Want to chat, play a game, or just take it easy? 🐼"
            "sad" -> "I'm here for you, friend. It's okay to feel this way. Would you like some comfort, a distraction, or just someone to be with? 💙"
            "anxious" -> "I can sense those worried feelings. Let's take this moment by moment together. Want to try something calming, or talk it out? 🫂"
            "tired" -> "You've been working so hard. Let's find a gentle way to help you feel better. Maybe something relaxing? 🌙"
            else -> "I'm so glad you're here! How can I brighten your day? 🐼"
        }
    }

    private fun setupNavigation() {
        binding.settingsButton.setOnClickListener {
            SoundManager.playClickSound(this)
            showSettingsDialog()
        }

        binding.shopButton.setOnClickListener {
            SoundManager.playClickSound(this)
            LoadingActivity.startWithTarget(this, ShopActivity::class.java)
        }

        binding.clawMachineButton.setOnClickListener {
            SoundManager.playClickSound(this)
            LoadingActivity.startWithTarget(this, ClawMachineActivity::class.java)
        }

        binding.customizeButton.setOnClickListener {
            SoundManager.playClickSound(this)
            showCustomizeDialog()
        }
    }

    private fun setupCharacterInteraction() {
        binding.characterImage.setOnClickListener {
            SoundManager.playClickSound(this)
            // Exit conversation mode if active, then navigate to mood selection
            if (isConversationMode) {
                exitConversationMode()
            }
            val intent = Intent(this, MoodSelectionActivity::class.java)
            startActivity(intent)
        }
    }

    private fun setupActionButtons() {
        binding.jokeButton.setOnClickListener {
            if (isConversationMode) return@setOnClickListener // Guard against accidental clicks
            SoundManager.playClickSound(this)
            binding.conversationText.text = ConversationManager.getRandomJoke()
        }

        binding.affirmationButton.setOnClickListener {
            if (isConversationMode) return@setOnClickListener // Guard against accidental clicks
            SoundManager.playClickSound(this)
            binding.conversationText.text = ConversationManager.getRandomAffirmation()
        }

        binding.selfCareButton.setOnClickListener {
            if (isConversationMode) return@setOnClickListener // Guard against accidental clicks
            SoundManager.playClickSound(this)
            binding.conversationText.text = ConversationManager.getRandomSelfCare()
        }

        binding.goodbyeButton.setOnClickListener {
            if (isConversationMode) return@setOnClickListener // Guard against accidental clicks
            SoundManager.playClickSound(this)
            binding.conversationText.text = ConversationManager.getRandomGoodbye()
            handler.postDelayed({
                finishAffinity()
            }, 3000)
        }
    }

    private fun setupButtonToggle() {
        binding.buttonToggleButton.setOnClickListener {
            SoundManager.playClickSound(this)
            toggleButtonContainers()
        }
    }

    private fun toggleButtonContainers() {
        if (isConversationMode) {
            // In conversation mode: toggle between conversation choices and static buttons
            isShowingStaticButtons = !isShowingStaticButtons

            if (isShowingStaticButtons) {
                // Show static buttons, hide conversation choices
                binding.defaultButtonsContainer.visibility = View.VISIBLE
                binding.conversationChoicesContainer.visibility = View.GONE
                binding.buttonToggleButton.text = "💬 Show Choices"
            } else {
                // Show conversation choices, hide static buttons
                binding.defaultButtonsContainer.visibility = View.GONE
                binding.conversationChoicesContainer.visibility = View.VISIBLE
                binding.buttonToggleButton.text = "📋 Show Menu"
            }
        } else {
            // Not in conversation mode: can only show static buttons
            // But we can create mock conversation choices for demonstration
            createMockConversationChoices()
            isShowingStaticButtons = !isShowingStaticButtons

            if (isShowingStaticButtons) {
                binding.defaultButtonsContainer.visibility = View.VISIBLE
                binding.conversationChoicesContainer.visibility = View.GONE
                binding.buttonToggleButton.text = "💬 Show Choices"
            } else {
                binding.defaultButtonsContainer.visibility = View.GONE
                binding.conversationChoicesContainer.visibility = View.VISIBLE
                binding.buttonToggleButton.text = "📋 Show Menu"
            }
        }
    }

    private fun createMockConversationChoices() {
        binding.conversationChoicesContainer.removeAllViews()

        val mockChoices = listOf(
            "How are you today?" to "happy_start",
            "I need some encouragement" to "show_affirmation",
            "Tell me something funny" to "show_joke",
            "I want to try self-care" to "show_selfcare"
        )

        mockChoices.forEachIndexed { index, (text, action) ->
            val button = com.google.android.material.button.MaterialButton(
                this,
                null,
                com.google.android.material.R.attr.materialButtonOutlinedStyle
            )
            button.apply {
                this.text = text
                textSize = 15f
                setTextColor(getColor(R.color.white))
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

                setOnClickListener {
                    SoundManager.playClickSound(this@MainActivity)
                    handleMockChoice(action)
                }
            }

            binding.conversationChoicesContainer.addView(button)
        }
    }

    private fun handleMockChoice(action: String) {
        when (action) {
            "show_affirmation" -> {
                binding.conversationText.text = ConversationManager.getRandomAffirmation()
            }
            "show_joke" -> {
                binding.conversationText.text = ConversationManager.getRandomJoke()
            }
            "show_selfcare" -> {
                binding.conversationText.text = ConversationManager.getRandomSelfCare()
            }
            "happy_start" -> {
                val intent = Intent(this, MoodSelectionActivity::class.java)
                startActivity(intent)
            }
        }
    }

    private fun showCustomizeDialog() {
        val dialogBinding = DialogCustomizeBinding.inflate(LayoutInflater.from(this))
        val dialog = AlertDialog.Builder(this, R.style.CustomDialogTheme)
            .setView(dialogBinding.root)
            .create()

        // Use Room Database for currency and BGM ownership (not SharedPreferences)
        lifecycleScope.launch {
            // Load from database
            var currency = userRepository.getCurrency()
            val ownedBGMs = userRepository.getPurchasedBgmList().toMutableList()
            // Kakushigoto is always owned
            if (!ownedBGMs.contains("kakushigoto")) {
                ownedBGMs.add("kakushigoto")
            }
            var selectedBgm = userRepository.getSelectedBgm()

            // Update currency display
            dialogBinding.currencyText.text = String.format("%,d", currency)

            // Update button states based on ownership
            updateCustomizeBGMButton(dialogBinding.bgmKakushigotoButton, "kakushigoto",
                0, ownedBGMs.toSet(), selectedBgm, true)
            updateCustomizeBGMButton(dialogBinding.bgmLittleButton, "little",
                500, ownedBGMs.toSet(), selectedBgm, false)
            updateCustomizeBGMButton(dialogBinding.bgmOrdinaryButton, "ordinary",
                1000, ownedBGMs.toSet(), selectedBgm, false)

            // Kakushigoto button (always unlocked)
            dialogBinding.bgmKakushigotoButton.setOnClickListener {
                SoundManager.playClickSound(this@MainActivity)
                lifecycleScope.launch {
                    selectBGMInDialogDB("kakushigoto", R.raw.main_bgm_kakushigoto)
                    selectedBgm = "kakushigoto"
                    updateDialogBGMSelection(dialogBinding, selectedBgm, ownedBGMs.toSet(), currency)
                }
            }

            // Little button (500 currency)
            dialogBinding.bgmLittleButton.setOnClickListener {
                SoundManager.playClickSound(this@MainActivity)
                lifecycleScope.launch {
                    if (ownedBGMs.contains("little")) {
                        selectBGMInDialogDB("little", R.raw.main_bgm_little)
                        selectedBgm = "little"
                        updateDialogBGMSelection(dialogBinding, selectedBgm, ownedBGMs.toSet(), currency)
                    } else {
                        // Try to purchase using database
                        if (currency >= 500) {
                            userRepository.spendCurrency(500)
                            currency = userRepository.getCurrency()
                            ownedBGMs.add("little")
                            // Record purchase in database
                            userRepository.purchaseBgm("little")
                            dialogBinding.currencyText.text = String.format("%,d", currency)
                            selectBGMInDialogDB("little", R.raw.main_bgm_little)
                            selectedBgm = "little"
                            updateDialogBGMSelection(dialogBinding, selectedBgm, ownedBGMs.toSet(), currency)
                            dialogBinding.bubbleText.text = "Unlocked! Enjoy your new music! 🎵"
                        } else {
                            dialogBinding.bubbleText.text = "Not enough currency! Play the claw machine to earn more! ✷"
                        }
                    }
                }
            }

            // Ordinary Days button (1000 currency)
            dialogBinding.bgmOrdinaryButton.setOnClickListener {
                SoundManager.playClickSound(this@MainActivity)
                lifecycleScope.launch {
                    if (ownedBGMs.contains("ordinary")) {
                        selectBGMInDialogDB("ordinary", R.raw.main_bgm_ordinary_days)
                        selectedBgm = "ordinary"
                        updateDialogBGMSelection(dialogBinding, selectedBgm, ownedBGMs.toSet(), currency)
                    } else {
                        // Try to purchase using database
                        if (currency >= 1000) {
                            userRepository.spendCurrency(1000)
                            currency = userRepository.getCurrency()
                            ownedBGMs.add("ordinary")
                            // Record purchase in database
                            userRepository.purchaseBgm("ordinary")
                            dialogBinding.currencyText.text = String.format("%,d", currency)
                            selectBGMInDialogDB("ordinary", R.raw.main_bgm_ordinary_days)
                            selectedBgm = "ordinary"
                            updateDialogBGMSelection(dialogBinding, selectedBgm, ownedBGMs.toSet(), currency)
                            dialogBinding.bubbleText.text = "Unlocked! This one's really nice! 🎶"
                        } else {
                            dialogBinding.bubbleText.text = "Not enough currency! Play the claw machine to earn more! ✷"
                        }
                    }
                }
            }

            dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

            dialogBinding.closeButton.setOnClickListener {
                SoundManager.playClickSound(this@MainActivity)
                dialog.dismiss()
            }

            dialog.show()
        }
    }

    private fun updateCustomizeBGMButton(
        button: com.google.android.material.button.MaterialButton,
        bgmKey: String,
        price: Int,
        ownedBGMs: Set<String>,
        selectedBgm: String,
        alwaysUnlocked: Boolean
    ) {
        val isOwned = alwaysUnlocked || ownedBGMs.contains(bgmKey)
        val isSelected = selectedBgm == bgmKey

        if (isOwned) {
            // Unlocked - show name with music emoji
            val name = when(bgmKey) {
                "kakushigoto" -> "Kakushigoto"
                "little" -> "Little"
                "ordinary" -> "Ordinary Days"
                else -> bgmKey
            }
            button.text = if (isSelected) "▶ $name" else "🎵 $name"
            button.setTextColor(getColor(R.color.green))
            button.strokeColor = android.content.res.ColorStateList.valueOf(getColor(R.color.green))
            button.strokeWidth = if (isSelected) 4 else 2
        } else {
            // Locked - show price
            val name = when(bgmKey) {
                "little" -> "Little"
                "ordinary" -> "Ordinary Days"
                else -> bgmKey
            }
            button.text = "🔒 $name - $price ✷"
            button.setTextColor(getColor(R.color.gray))
            button.strokeColor = android.content.res.ColorStateList.valueOf(getColor(R.color.gray))
            button.strokeWidth = 2
        }
    }

    private suspend fun selectBGMInDialogDB(bgmKey: String, resId: Int) {
        userRepository.setSelectedBgm(bgmKey)
        SoundManager.stopBGM()
        SoundManager.playBGM(this, resId)
    }

    private fun updateDialogBGMSelection(
        dialogBinding: DialogCustomizeBinding,
        selectedBgm: String,
        ownedBGMs: Set<String>,
        currency: Int
    ) {
        updateCustomizeBGMButton(dialogBinding.bgmKakushigotoButton, "kakushigoto",
            0, ownedBGMs, selectedBgm, true)
        updateCustomizeBGMButton(dialogBinding.bgmLittleButton, "little",
            500, ownedBGMs, selectedBgm, false)
        updateCustomizeBGMButton(dialogBinding.bgmOrdinaryButton, "ordinary",
            1000, ownedBGMs, selectedBgm, false)
    }

    private fun showSettingsDialog() {
        val dialogBinding = DialogSettingsBinding.inflate(LayoutInflater.from(this))
        val dialog = AlertDialog.Builder(this, R.style.CustomDialogTheme)
            .setView(dialogBinding.root)
            .create()

        val prefs = getSharedPreferences("BaoBaoPrefs", MODE_PRIVATE)

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
            // TODO: Apply to SoundManager when SFX system is implemented
        }

        // Voice slider listener
        dialogBinding.voiceSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            prefs.edit().putFloat("voice_volume", volume).apply()
            dialogBinding.voiceValueText.text = "${value.toInt()}%"
            // TODO: Apply to voice system when implemented
        }

        dialogBinding.bubbleText.text = ConversationManager.getRandomSettings()

        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)

        dialogBinding.signOutButton.setOnClickListener {
            dialog.dismiss()
            val intent = Intent(this, AuthActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivity(intent)
        }

        dialogBinding.closeButton.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    override fun onResume() {
        super.onResume()
        handler.post(timeUpdater)

        // Load BGM from database
        lifecycleScope.launch {
            val selectedBgm = userRepository.getSelectedBgm()
            val resId = getBgmResourceForKey(selectedBgm)
            SoundManager.playBGM(this@MainActivity, resId)
        }
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacks(timeUpdater)
    }

    // ========== CONVERSATION SYSTEM ==========

    private fun startConversation(mood: String) {
        currentMood = mood
        isConversationMode = true
        isShowingStaticButtons = false // Start with conversation choices visible
        conversationPath.clear()

        // Show toggle button when entering conversation mode
        binding.buttonToggleButton.visibility = View.VISIBLE
        binding.buttonToggleButton.text = "📋 Show Menu"

        lifecycleScope.launch {
            val userData = userRepository.getUserData()

            // Check if intervention should be triggered
            if (InterventionManager.shouldTriggerIntervention(userData)) {
                currentMood = "intervention"
                val updatedData = InterventionManager.markInterventionShown(userData)
                userRepository.updateUserData(updatedData)
            }

            // Load starting node
            val startingNode = ConversationManager.getStartingNode(currentMood!!)
            showConversationNode(startingNode)
        }
    }

    private fun showConversationNode(node: ConversationNode) {
        currentNode = node
        conversationPath.add(node.id)

        // Update conversation text
        binding.conversationText.text = node.baobaoLine

        // Animate character
        binding.characterImage.animate()
            .scaleX(1.1f)
            .scaleY(1.1f)
            .setDuration(150)
            .withEndAction {
                binding.characterImage.animate()
                    .scaleX(1.0f)
                    .scaleY(1.0f)
                    .setDuration(150)
                    .start()
            }
            .start()

        // Show feature nudge if present
        node.featureNudge?.let { feature ->
            showFeatureNudge(feature)
        } ?: run {
            binding.featureNudgeCard.visibility = View.GONE
        }

        // Show conversation choices
        showConversationChoices(node.userOptions)
    }

    private fun showFeatureNudge(feature: String) {
        val nudgeText = when (feature) {
            "joke" -> "💡 Want a laugh? Tap here to hear BaoBao's jokes!"
            "claw-machine" -> "💡 Ready for some fun? Try the Claw Machine game!"
            "self-care" -> "💡 Need gentle care? Tap for self-care suggestions!"
            "shop" -> "💡 Curious about customizations? Check out the shop!"
            "affirmation" -> "💡 Need encouragement? Tap for daily affirmations!"
            else -> ""
        }

        if (nudgeText.isNotBlank()) {
            binding.featureNudgeText.text = nudgeText
            binding.featureNudgeCard.visibility = View.VISIBLE
            binding.featureNudgeCard.setOnClickListener {
                SoundManager.playClickSound(this)
                navigateToFeature(feature)
            }
        } else {
            binding.featureNudgeCard.visibility = View.GONE
        }
    }

    private fun navigateToFeature(feature: String) {
        when (feature) {
            "joke" -> {
                exitConversationMode()
                binding.conversationText.text = ConversationManager.getRandomJoke()
            }
            "claw-machine" -> {
                LoadingActivity.startWithTarget(this, ClawMachineActivity::class.java)
            }
            "self-care" -> {
                exitConversationMode()
                binding.conversationText.text = ConversationManager.getRandomSelfCare()
            }
            "shop" -> {
                LoadingActivity.startWithTarget(this, ShopActivity::class.java)
            }
            "affirmation" -> {
                exitConversationMode()
                binding.conversationText.text = ConversationManager.getRandomAffirmation()
            }
        }
    }

    private fun showConversationChoices(options: List<com.example.baobao.models.UserOption>) {
        // Hide default buttons, show conversation choices
        binding.defaultButtonsContainer.visibility = View.GONE
        binding.conversationChoicesContainer.visibility = View.VISIBLE
        binding.conversationChoicesContainer.removeAllViews()

        options.forEachIndexed { index, option ->
            val button = MaterialButton(this, null, com.google.android.material.R.attr.materialButtonOutlinedStyle)
            button.apply {
                text = option.text
                textSize = 15f
                setTextColor(getColor(R.color.white))
                setPadding(16, 16, 16, 16)
                isAllCaps = false
                cornerRadius = 16
                strokeWidth = 3

                // Alternate button colors for variety
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

                setOnClickListener {
                    SoundManager.playClickSound(this@MainActivity)
                    onUserChoice(option.nextNodeId, option.moodEffect)
                }
            }

            binding.conversationChoicesContainer.addView(button)
        }
    }

    private fun onUserChoice(nextNodeId: String, moodEffect: Int) {
        // Check if choice leads to resources screen
        if (nextNodeId == "show_resources_screen") {
            val intent = Intent(this, ResourcesActivity::class.java)
            startActivity(intent)
            return
        }

        // Check if this choice leads to mood selector (loop point)
        if (nextNodeId == "return_to_mood" || ConversationManager.isLoopPoint(nextNodeId)) {
            saveConversationState()
            returnToMoodSelector()
            return
        }

        // Get the next node
        val nextNode = ConversationManager.getNodeById(currentMood!!, nextNodeId)

        if (nextNode != null) {
            // Apply mood effect if any
            if (moodEffect != 0) {
                applyMoodEffect(moodEffect)
            }

            // Show next node
            showConversationNode(nextNode)
        } else {
            // Fallback: return to mood selector if node not found
            returnToMoodSelector()
        }
    }

    private fun saveConversationState() {
        lifecycleScope.launch {
            val userData = userRepository.getUserData()

            // Convert conversation path to JSON array string
            val pathJson = org.json.JSONArray(conversationPath).toString()

            val updatedData = userData.copy(
                currentMood = currentMood ?: "okay",
                currentConversationPath = pathJson,
                lastConversationNodeId = currentNode?.id ?: ""
            )
            userRepository.updateUserData(updatedData)
        }
    }

    private fun applyMoodEffect(effect: Int) {
        // Apply mood effect to emotional weight in database
        // Positive effect reduces emotional weight (therapeutic benefit from conversations)
        lifecycleScope.launch {
            val userData = userRepository.getUserData()
            val newWeight = (userData.emotionalWeight - effect).coerceIn(0, 10)
            val updatedData = userData.copy(emotionalWeight = newWeight)
            userRepository.updateUserData(updatedData)
        }

        // Visual feedback for mood improvement
        if (effect > 0) {
            // Subtle bounce animation on character to show positive effect
            binding.characterImage.animate()
                .scaleX(1.15f)
                .scaleY(1.15f)
                .setDuration(200)
                .withEndAction {
                    binding.characterImage.animate()
                        .scaleX(1.0f)
                        .scaleY(1.0f)
                        .setDuration(200)
                        .start()
                }
                .start()
        }
    }

    private fun returnToMoodSelector() {
        exitConversationMode()
        val intent = Intent(this, MoodSelectionActivity::class.java)
        startActivity(intent)
    }

    private fun exitConversationMode() {
        isConversationMode = false
        currentMood = null
        currentNode = null
        conversationPath.clear()
        isShowingStaticButtons = true // Reset to default state

        // Hide toggle button and conversation UI
        binding.buttonToggleButton.visibility = View.GONE
        binding.conversationChoicesContainer.visibility = View.GONE
        binding.defaultButtonsContainer.visibility = View.VISIBLE
        binding.featureNudgeCard.visibility = View.GONE
    }

    // ========== END CONVERSATION SYSTEM ==========

    private fun updateStatus() {
        val now = Date()
        val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault())
        
        binding.timeText.text = timeFormat.format(now)
        binding.dateText.text = dateFormat.format(now)

        // Show user's actual mood - either from current session or from database
        if (currentMood != null) {
            showMoodInStatus(currentMood!!)
        } else {
            // Load user's last saved mood from database
            lifecycleScope.launch {
                val userData = userRepository.getUserData()
                val savedMood = userData.currentMood
                if (savedMood.isNotBlank() && savedMood != "okay") {
                    // Show the user's last saved mood
                    showMoodInStatus(savedMood)
                } else {
                    // Default to time-based greeting only for first-time users
                    val hour = SimpleDateFormat("HH", Locale.getDefault()).format(now).toInt()
                    val (emoji, mood) = when (hour) {
                        in 5..11 -> "🌅" to "Morning"
                        in 12..17 -> "☀️" to "Afternoon"
                        in 18..21 -> "🌙" to "Evening"
                        else -> "🌟" to "Night"
                    }
                    binding.moodText.text = "$emoji $mood"
                }
            }
        }
    }

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
}