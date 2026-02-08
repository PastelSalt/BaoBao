package com.example.baobao.coreoperations

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.R
import com.example.baobao.audio.SoundManager

abstract class BaseActivity : AppCompatActivity() {

    protected open fun getBgmResource(): Int = R.raw.main_bgm

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()
        val resId = getBgmResource()
        if (resId != 0) {
            SoundManager.playBGM(this, resId)
        }
    }

    override fun onPause() {
        super.onPause()
        SoundManager.pauseBGM()
    }
}

