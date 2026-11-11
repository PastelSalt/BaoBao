package com.example.baobao.intervention

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.MainActivity
import com.example.baobao.audio.SoundManager
import com.example.baobao.databinding.ActivityResourcesBinding

class ResourcesActivity : AppCompatActivity() {

    private lateinit var binding: ActivityResourcesBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityResourcesBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupButtons()
    }

    private fun setupButtons() {
        // Crisis Text Line
        binding.crisisTextButton.setOnClickListener {
            SoundManager.playClickSound(this)
            val smsIntent = Intent(Intent.ACTION_VIEW, Uri.parse("sms:741741"))
            smsIntent.putExtra("sms_body", "HELLO")
            startActivity(smsIntent)
        }

        // National Suicide Prevention Lifeline
        binding.suicidePreventionButton.setOnClickListener {
            SoundManager.playClickSound(this)
            val callIntent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:988"))
            startActivity(callIntent)
        }

        // SAMHSA National Helpline
        binding.samhsaButton.setOnClickListener {
            SoundManager.playClickSound(this)
            val callIntent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:1-800-662-4357"))
            startActivity(callIntent)
        }

        // NAMI Helpline
        binding.namiButton.setOnClickListener {
            SoundManager.playClickSound(this)
            val callIntent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:1-800-950-6264"))
            startActivity(callIntent)
        }

        // Learn More (opens mental health resources website)
        binding.learnMoreButton.setOnClickListener {
            SoundManager.playClickSound(this)
            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.mentalhealth.gov/get-help/immediate-help"))
            startActivity(browserIntent)
        }

        // Close button
        binding.closeButton.setOnClickListener {
            SoundManager.playClickSound(this)
            finish()
        }

        // Return to mood check-in
        binding.returnToMoodButton.setOnClickListener {
            SoundManager.playClickSound(this)
            val intent = Intent(this, MainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
            startActivity(intent)
            finish()
        }
    }
}

