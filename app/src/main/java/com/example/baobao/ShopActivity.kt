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

        binding.bubbleText.text = ConversationManager.getRandomShop()

        // Load and display currency
        updateCurrencyDisplay()
    }

    override fun onResume() {
        super.onResume()
        updateCurrencyDisplay()
    }

    private fun updateCurrencyDisplay() {
        lifecycleScope.launch {
            val currency = userRepository.getCurrency()
            binding.currencyText.text = String.format("%,d", currency)
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