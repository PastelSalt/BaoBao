package com.example.baobao

import android.content.Intent
import android.os.Bundle
import com.example.baobao.databinding.ActivityShopBinding

class ShopActivity : BaseActivity() {
    private lateinit var binding: ActivityShopBinding

    override fun getBgmResource(): Int = R.raw.shop_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityShopBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.backButton.setOnClickListener {
            goBackWithLoading()
        }

        binding.bubbleText.text = ConversationManager.getRandomShop()
    }

    override fun onBackPressed() {
        goBackWithLoading()
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