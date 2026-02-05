package com.example.baobao

import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.lifecycleScope
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

        binding.backButton.setOnClickListener {
            SoundManager.playClickSound(this)
            goBackWithLoading()
        }

        val (text, index) = ConversationManager.getRandomShopWithIndex()
        binding.bubbleText.text = text
        VoiceManager.playVoice(this, VoiceManager.getShopAudioId(this, index))

        // Load and display currency
        updateCurrencyDisplay()

        // Setup BGM purchase functionality
        setupBgmPurchases()
    }

    override fun onResume() {
        super.onResume()
        updateCurrencyDisplay()
        updateBgmPurchaseStates()
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
            purchaseBgm("little", 500)
        }

        // Setup Ordinary Days BGM purchase
        binding.bgmOrdinaryCard.setOnClickListener {
            SoundManager.playClickSound(this)
            purchaseBgm("ordinary", 750)
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
                    return@launch
                }

                // Spend currency
                if (userRepository.spendCurrency(cost)) {
                    // Purchase BGM
                    userRepository.purchaseBgm(bgmKey)

                    // Update displays
                    updateCurrencyDisplay()
                    updateBgmPurchaseStates()

                    // Show success message
                    android.widget.Toast.makeText(this@ShopActivity, "BGM purchased! Check customize dialog to use it.", android.widget.Toast.LENGTH_LONG).show()

                    // Update bubble text
                    binding.bubbleText.text = "Great choice! You can change your BGM anytime in the customize menu."
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