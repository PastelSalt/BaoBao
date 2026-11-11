package com.example.baobao.coreoperations

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.baobao.audio.SoundManager

abstract class BaseActivity : AppCompatActivity() {

    /** Raw resource id of the screen BGM; 0 means the screen manages music itself. */
    protected open fun getBgmResource(): Int = 0

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

