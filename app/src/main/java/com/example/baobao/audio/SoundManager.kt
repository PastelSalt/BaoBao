package com.example.baobao.audio

import android.content.Context
import android.media.MediaPlayer
import com.example.baobao.R

object SoundManager {
    private var mediaPlayer: MediaPlayer? = null
    private var sfxPlayer: MediaPlayer? = null
    private var currentResId: Int = 0

    fun playBGM(context: Context, resId: Int) {
        if (currentResId == resId) {
            if (mediaPlayer?.isPlaying == false) {
                mediaPlayer?.start()
            }
            return
        }

        stopBGM()

        try {
            mediaPlayer = MediaPlayer.create(context.applicationContext, resId)
            mediaPlayer?.isLooping = true
            currentResId = resId
            applyVolume(context)
            mediaPlayer?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun applyVolume(context: Context) {
        val prefs = context.getSharedPreferences("BaoBaoPrefs", Context.MODE_PRIVATE)
        val bgmVolume = prefs.getFloat("bgm_volume", 0.7f)
        mediaPlayer?.setVolume(bgmVolume, bgmVolume)
    }

    fun setVolume(volume: Float) {
        mediaPlayer?.setVolume(volume, volume)
    }

    fun pauseBGM() {
        if (mediaPlayer?.isPlaying == true) {
            mediaPlayer?.pause()
        }
    }

    fun stopBGM() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        currentResId = 0
    }

    // SFX Support
    fun playClickSound(context: Context) {
        val prefs = context.getSharedPreferences("BaoBaoPrefs", Context.MODE_PRIVATE)
        val sfxVolume = prefs.getFloat("sfx_volume", 0.8f)

        try {
            sfxPlayer?.release()
            sfxPlayer = MediaPlayer.create(context.applicationContext, R.raw.click_sfx)
            sfxPlayer?.setVolume(sfxVolume, sfxVolume)
            sfxPlayer?.setOnCompletionListener { mp ->
                mp.release()
            }
            sfxPlayer?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}