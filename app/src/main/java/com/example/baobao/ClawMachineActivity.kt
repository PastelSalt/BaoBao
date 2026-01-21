package com.example.baobao

import android.content.Intent
import android.os.Bundle
import com.example.baobao.databinding.ActivityClawMachineBinding

class ClawMachineActivity : BaseActivity() {
    private lateinit var binding: ActivityClawMachineBinding

    override fun getBgmResource(): Int = R.raw.clawmachine_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityClawMachineBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.backButton.setOnClickListener {
            goBackWithLoading()
        }

        binding.bubbleText.text = ConversationManager.getRandomClawMachine()
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