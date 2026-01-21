package com.example.baobao

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.databinding.ActivityLoadingBinding

class LoadingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoadingBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityLoadingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val targetActivityName = intent.getStringExtra("TARGET_ACTIVITY")
        val delay = intent.getLongExtra("DELAY", 750L)
        val flags = intent.getIntExtra("FLAGS", 0)

        Handler(Looper.getMainLooper()).postDelayed({
            if (targetActivityName != null) {
                try {
                    val targetClass = Class.forName(targetActivityName)
                    val intent = Intent(this, targetClass)
                    if (flags != 0) {
                        intent.flags = flags
                    }
                    startActivity(intent)
                } catch (e: ClassNotFoundException) {
                    e.printStackTrace()
                }
            }
            finish()
        }, delay)
    }

    companion object {
        fun startWithTarget(
            activity: AppCompatActivity, 
            targetClass: Class<*>, 
            delay: Long = 750L,
            flags: Int = 0
        ) {
            val intent = Intent(activity, LoadingActivity::class.java).apply {
                putExtra("TARGET_ACTIVITY", targetClass.name)
                putExtra("DELAY", delay)
                putExtra("FLAGS", flags)
            }
            activity.startActivity(intent)
        }
    }
}