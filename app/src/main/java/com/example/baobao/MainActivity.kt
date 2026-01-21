package com.example.baobao

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import androidx.appcompat.app.AlertDialog
import com.example.baobao.databinding.ActivityMainBinding
import com.example.baobao.databinding.DialogSettingsBinding
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : BaseActivity() {

    private lateinit var binding: ActivityMainBinding
    private val handler = Handler(Looper.getMainLooper())
    private val timeUpdater = object : Runnable {
        override fun run() {
            updateStatus()
            handler.postDelayed(this, 1000)
        }
    }

    override fun getBgmResource(): Int = R.raw.main_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Navigation Buttons
        binding.settingsButton.setOnClickListener {
            showSettingsDialog()
        }

        binding.shopButton.setOnClickListener {
            LoadingActivity.startWithTarget(this, ShopActivity::class.java)
        }

        binding.clawMachineButton.setOnClickListener {
            LoadingActivity.startWithTarget(this, ClawMachineActivity::class.java)
        }

        // Action Buttons
        binding.jokeButton.setOnClickListener {
            binding.conversationText.text = ConversationManager.getRandomJoke()
        }

        binding.affirmationButton.setOnClickListener {
            binding.conversationText.text = ConversationManager.getRandomAffirmation()
        }

        binding.selfCareButton.setOnClickListener {
            binding.conversationText.text = ConversationManager.getRandomSelfCare()
        }

        binding.goodbyeButton.setOnClickListener {
            binding.conversationText.text = ConversationManager.getRandomGoodbye()
            handler.postDelayed({
                finishAffinity()
            }, 3000)
        }

        updateStatus()
    }

    private fun showSettingsDialog() {
        val dialogBinding = DialogSettingsBinding.inflate(LayoutInflater.from(this))
        val dialog = AlertDialog.Builder(this, R.style.CustomDialogTheme)
            .setView(dialogBinding.root)
            .create()

        val prefs = getSharedPreferences("BaoBaoPrefs", Context.MODE_PRIVATE)
        val currentVolume = prefs.getFloat("bgm_volume", 0.7f)
        dialogBinding.bgmSlider.value = currentVolume * 100f

        dialogBinding.bgmSlider.addOnChangeListener { _, value, _ ->
            val volume = value / 100f
            SoundManager.setVolume(volume)
            prefs.edit().putFloat("bgm_volume", volume).apply()
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
    }

    override fun onPause() {
        super.onPause()
        handler.removeCallbacks(timeUpdater)
    }

    private fun updateStatus() {
        val now = Date()
        val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
        val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault())
        
        binding.timeText.text = timeFormat.format(now)
        binding.dateText.text = dateFormat.format(now)
    }
}