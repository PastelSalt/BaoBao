package com.example.baobao

import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.lifecycleScope
import com.example.baobao.additionals.LoadingActivity
import com.example.baobao.audio.SoundManager
import com.example.baobao.audio.VoiceManager
import com.example.baobao.conversation.ConversationManager
import com.example.baobao.coreoperations.AnimationManager
import com.example.baobao.coreoperations.BaseActivity
import com.example.baobao.coreoperations.CharacterImageManager
import com.example.baobao.database.AppDatabase
import com.example.baobao.database.UserRepository
import com.example.baobao.databinding.ActivityShopBinding
import kotlinx.coroutines.launch

class ShopActivity : BaseActivity() {
    private lateinit var binding: ActivityShopBinding
    private lateinit var userRepository: UserRepository

    override fun getBgmResource(): Int = R.raw.shop_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityShopBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize database
        val database = AppDatabase.getDatabase(this)
        userRepository = UserRepository(database.userDao())

        // Apply voice settings
        VoiceManager.applySettings(this)

        binding.backButton.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.buttonPressEffect(it) {
                goBackWithLoading()
            }
        }

        val (text, index) = ConversationManager.getRandomShopWithIndex()
        binding.bubbleText.text = text
        VoiceManager.playVoice(this, VoiceManager.getShopAudioId(this, index))

        // Load and display currency
        updateCurrencyDisplay()

        // Load and apply selected outfit to character icon
        loadSelectedOutfit()

        // Setup BGM purchase functionality
        setupBgmPurchases()

        // Setup outfit purchase functionality
        setupOutfitPurchases()

        // Setup background purchase functionality
        setupBackgroundPurchases()

        // Start entrance animations
        startEntranceAnimations()
    }

    private fun startEntranceAnimations() {
        // Header slide in from top
        AnimationManager.slideInDown(binding.headerLayout, delay = 50)

        // Character icon bounce in
        AnimationManager.bounceIn(binding.characterIcon, delay = 200)

        // Speech bubble pop in
        AnimationManager.popIn(binding.speechBubble, delay = 300)
    }

    override fun onResume() {
        super.onResume()
        updateCurrencyDisplay()
        updateBgmPurchaseStates()
        updateOutfitPurchaseStates()
        updateBackgroundPurchaseStates()
        loadSelectedOutfit()
    }

    private fun loadSelectedOutfit() {
        lifecycleScope.launch {
            val selectedOutfit = userRepository.getSelectedOutfit()
            CharacterImageManager.setOutfit(selectedOutfit)
            // Update character icon with current outfit
            binding.characterIcon.setImageResource(
                CharacterImageManager.getCharacterImage(CharacterImageManager.Emotion.HELLO)
            )
        }
    }

    private fun updateCurrencyDisplay() {
        lifecycleScope.launch {
            val currency = userRepository.getCurrency()
            binding.currencyText.text = String.format("%,d", currency)
        }
    }

    private fun setupBgmPurchases() {
        // Setup Little BGM purchase
        binding.bgmLittleCard.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.cardTapEffect(it) {
                purchaseBgm("little", 500)
            }
        }

        // Setup Ordinary Days BGM purchase
        binding.bgmOrdinaryCard.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.cardTapEffect(it) {
                purchaseBgm("ordinary", 750)
            }
        }

        // Update initial states
        updateBgmPurchaseStates()
    }

    private fun updateBgmPurchaseStates() {
        lifecycleScope.launch {
            val purchasedBgm = userRepository.getPurchasedBgmList()
            val currency = userRepository.getCurrency()

            // Update Little BGM state
            updateBgmCardState(
                binding.bgmLittleCard,
                binding.bgmLittlePrice,
                "little",
                500,
                purchasedBgm,
                currency
            )

            // Update Ordinary Days BGM state
            updateBgmCardState(
                binding.bgmOrdinaryCard,
                binding.bgmOrdinaryPrice,
                "ordinary",
                750,
                purchasedBgm,
                currency
            )
        }
    }

    private fun updateBgmCardState(
        card: android.view.View,
        priceText: android.widget.TextView,
        bgmKey: String,
        price: Int,
        purchasedBgm: List<String>,
        currency: Int
    ) {
        val isPurchased = purchasedBgm.contains(bgmKey)
        val canAfford = currency >= price

        if (isPurchased) {
            priceText.text = "✓ Owned"
            priceText.setTextColor(getColor(R.color.green))
            card.alpha = 0.7f
            card.isClickable = false
        } else if (canAfford) {
            priceText.text = "$price ✷"
            priceText.setTextColor(getColor(R.color.green))
            card.alpha = 1.0f
            card.isClickable = true
        } else {
            priceText.text = "$price ✷"
            priceText.setTextColor(getColor(R.color.gray))
            card.alpha = 0.6f
            card.isClickable = false
        }
    }

    private fun purchaseBgm(bgmKey: String, cost: Int) {
        lifecycleScope.launch {
            val currentCurrency = userRepository.getCurrency()

            if (currentCurrency >= cost) {
                // Check if already purchased
                val purchasedBgm = userRepository.getPurchasedBgmList()
                if (purchasedBgm.contains(bgmKey)) {
                    android.widget.Toast.makeText(this@ShopActivity, "Already owned!", android.widget.Toast.LENGTH_SHORT).show()
                    AnimationManager.shake(binding.currencyCard)
                    return@launch
                }

                // Spend currency
                if (userRepository.spendCurrency(cost)) {
                    // Purchase BGM
                    userRepository.purchaseBgm(bgmKey)

                    // Update displays with celebration animation
                    AnimationManager.celebrationEffect(binding.currencyCard)
                    updateCurrencyDisplay()
                    updateBgmPurchaseStates()

                    // Show success message
                    android.widget.Toast.makeText(this@ShopActivity, "BGM purchased! Check customize dialog to use it.", android.widget.Toast.LENGTH_LONG).show()

                    // Update bubble text with animation
                    AnimationManager.fadeOut(binding.bubbleText, duration = 150, hideAfter = false) {
                        binding.bubbleText.text = "Great choice! You can change your BGM anytime in the customize menu."
                        AnimationManager.fadeIn(binding.bubbleText, duration = 200)
                    }
                } else {
                    android.widget.Toast.makeText(this@ShopActivity, "Purchase failed!", android.widget.Toast.LENGTH_SHORT).show()
                    AnimationManager.shake(binding.currencyCard)
                }
            } else {
                android.widget.Toast.makeText(this@ShopActivity, "Not enough currency! You need $cost ✷", android.widget.Toast.LENGTH_SHORT).show()
                AnimationManager.shake(binding.currencyCard)
                binding.bubbleText.text = "You need more coins for that! Try playing the claw machine or daily check-ins."
            }
        }
    }

    private fun setupOutfitPurchases() {
        // Setup Blue Bao outfit purchase (outfit2)
        binding.outfitBlueBaoCard.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.cardTapEffect(it) {
                purchaseOutfit("outfit2", 1000, "Blue Bao")
            }
        }

        // Update initial states
        updateOutfitPurchaseStates()
    }

    private fun updateOutfitPurchaseStates() {
        lifecycleScope.launch {
            val purchasedOutfits = userRepository.getPurchasedOutfitsList()
            val currency = userRepository.getCurrency()

            // Update Blue Bao outfit state
            updateOutfitCardState(
                binding.outfitBlueBaoCard,
                binding.outfitBlueBaoPrice,
                "outfit2",
                1000,
                purchasedOutfits,
                currency
            )
        }
    }

    private fun updateOutfitCardState(
        card: android.view.View,
        priceText: android.widget.TextView,
        outfitKey: String,
        price: Int,
        purchasedOutfits: List<String>,
        currency: Int
    ) {
        val isPurchased = purchasedOutfits.contains(outfitKey)
        val canAfford = currency >= price

        if (isPurchased) {
            priceText.text = "✓ Owned"
            priceText.setTextColor(getColor(R.color.green))
            card.alpha = 0.7f
            card.isClickable = false
        } else if (canAfford) {
            priceText.text = "$price ✷"
            priceText.setTextColor(getColor(R.color.green))
            card.alpha = 1.0f
            card.isClickable = true
        } else {
            priceText.text = "$price ✷"
            priceText.setTextColor(getColor(R.color.gray))
            card.alpha = 0.6f
            card.isClickable = false
        }
    }

    private fun setupBackgroundPurchases() {
        // Setup Bamboo Clouds background purchase
        binding.bgBambooCloudsCard.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.cardTapEffect(it) {
                purchaseBackground("bamboo_clouds", 800, "Bamboo Clouds")
            }
        }

        // Setup Bamboo Plum background purchase
        binding.bgBambooPlumCard.setOnClickListener {
            SoundManager.playClickSound(this)
            AnimationManager.cardTapEffect(it) {
                purchaseBackground("bamboo_plum", 1000, "Bamboo Plum")
            }
        }

        // Update initial states
        updateBackgroundPurchaseStates()
    }

    private fun updateBackgroundPurchaseStates() {
        lifecycleScope.launch {
            val purchasedBackgrounds = userRepository.getPurchasedBackgroundsList()
            val currency = userRepository.getCurrency()

            // Update Bamboo Clouds background state
            updateBackgroundCardState(
                binding.bgBambooCloudsCard,
                binding.bgBambooCloudsPrice,
                "bamboo_clouds",
                800,
                purchasedBackgrounds,
                currency
            )

            // Update Bamboo Plum background state
            updateBackgroundCardState(
                binding.bgBambooPlumCard,
                binding.bgBambooPlumPrice,
                "bamboo_plum",
                1000,
                purchasedBackgrounds,
                currency
            )
        }
    }

    private fun updateBackgroundCardState(
        card: android.view.View,
        priceText: android.widget.TextView,
        backgroundKey: String,
        price: Int,
        purchasedBackgrounds: List<String>,
        currency: Int
    ) {
        val isPurchased = purchasedBackgrounds.contains(backgroundKey)
        val canAfford = currency >= price

        if (isPurchased) {
            priceText.text = "✓ Owned"
            priceText.setTextColor(getColor(R.color.green))
            card.alpha = 0.7f
            card.isClickable = false
        } else if (canAfford) {
            priceText.text = "$price ✷"
            priceText.setTextColor(getColor(R.color.green))
            card.alpha = 1.0f
            card.isClickable = true
        } else {
            priceText.text = "$price ✷"
            priceText.setTextColor(getColor(R.color.gray))
            card.alpha = 0.6f
            card.isClickable = false
        }
    }

    private fun purchaseBackground(backgroundKey: String, cost: Int, backgroundName: String) {
        lifecycleScope.launch {
            val currentCurrency = userRepository.getCurrency()

            if (currentCurrency >= cost) {
                // Check if already purchased
                val purchasedBackgrounds = userRepository.getPurchasedBackgroundsList()
                if (purchasedBackgrounds.contains(backgroundKey)) {
                    android.widget.Toast.makeText(this@ShopActivity, "Already owned!", android.widget.Toast.LENGTH_SHORT).show()
                    return@launch
                }

                // Spend currency
                if (userRepository.spendCurrency(cost)) {
                    // Purchase background
                    userRepository.purchaseBackground(backgroundKey)

                    // Update displays
                    updateCurrencyDisplay()
                    updateBackgroundPurchaseStates()

                    // Show success message
                    android.widget.Toast.makeText(this@ShopActivity, "$backgroundName background purchased! Check customize dialog to use it.", android.widget.Toast.LENGTH_LONG).show()

                    // Update bubble text
                    binding.bubbleText.text = "Beautiful choice! You can change backgrounds in the customize menu!"
                } else {
                    android.widget.Toast.makeText(this@ShopActivity, "Purchase failed!", android.widget.Toast.LENGTH_SHORT).show()
                }
            } else {
                android.widget.Toast.makeText(this@ShopActivity, "Not enough currency! You need $cost ✷", android.widget.Toast.LENGTH_SHORT).show()
                binding.bubbleText.text = "You need more coins for that! Try playing the claw machine or daily check-ins."
            }
        }
    }

    private fun purchaseOutfit(outfitKey: String, cost: Int, outfitName: String) {
        lifecycleScope.launch {
            val currentCurrency = userRepository.getCurrency()

            if (currentCurrency >= cost) {
                // Check if already purchased
                val purchasedOutfits = userRepository.getPurchasedOutfitsList()
                if (purchasedOutfits.contains(outfitKey)) {
                    android.widget.Toast.makeText(this@ShopActivity, "Already owned!", android.widget.Toast.LENGTH_SHORT).show()
                    return@launch
                }

                // Spend currency
                if (userRepository.spendCurrency(cost)) {
                    // Purchase outfit
                    userRepository.purchaseOutfit(outfitKey)

                    // Update displays
                    updateCurrencyDisplay()
                    updateOutfitPurchaseStates()

                    // Show success message
                    android.widget.Toast.makeText(this@ShopActivity, "$outfitName outfit purchased! Check customize dialog to use it.", android.widget.Toast.LENGTH_LONG).show()

                    // Update bubble text
                    binding.bubbleText.text = "Yay! I look great in my new outfit! Change it in the customize menu!"
                } else {
                    android.widget.Toast.makeText(this@ShopActivity, "Purchase failed!", android.widget.Toast.LENGTH_SHORT).show()
                }
            } else {
                android.widget.Toast.makeText(this@ShopActivity, "Not enough currency! You need $cost ✷", android.widget.Toast.LENGTH_SHORT).show()
                binding.bubbleText.text = "You need more coins for that! Try playing the claw machine or daily check-ins."
            }
        }
    }

    private fun goBackWithLoading() {
        LoadingActivity.startWithTarget(
            this, 
            MainActivity::class.java, 
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
        finish()
    }
}