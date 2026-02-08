package com.example.baobao.audio

import android.content.Context
import android.media.MediaPlayer

/**
 * Manages voice line playback for BaoBao's dialogue
 *
 * Voice line sections:
 * - A (a_01-a_05): Sign-up
 * - B (b_01-b_05): Login
 * - C (c_01-c_05): Shop
 * - D (d_01-d_05): Settings
 * - E (e_01-e_10): Self-Care
 * - F (f_01-f_10): Affirmations
 * - G (g_01-g_10): Jokes
 * - H (h_01-h_05): Claw Machine
 * - I (i_01-i_05): Goodbye
 * - H_HAPPY (h_happy_01-h_happy_11): Happy mood conversations
 * - S_SAD (s_sad_01-s_sad_16): Sad mood conversations
 * - X_ANXIOUS (x_anxious_01-x_anxious_15): Anxious mood conversations
 * - T_TIRED (t_tired_01-t_tired_16): Tired mood conversations
 * - O_OKAY (o_okay_01-o_okay_13): Okay mood conversations
 * - INT (int_01-int_08): Intervention conversations
 */
object VoiceManager {
    private var voicePlayer: MediaPlayer? = null
    private var isVoiceEnabled = true
    private var voiceVolume = 1.0f

    /**
     * Play a voice line by resource ID
     */
    fun playVoice(context: Context, resId: Int) {
        if (!isVoiceEnabled || resId == 0) return

        stopVoice()

        try {
            voicePlayer = MediaPlayer.create(context.applicationContext, resId)
            voicePlayer?.apply {
                setVolume(voiceVolume, voiceVolume)
                setOnCompletionListener { mp ->
                    mp.release()
                    voicePlayer = null
                }
                start()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * Play a voice line by resource name (e.g., "a_01", "h_happy_01")
     */
    fun playVoiceByName(context: Context, resourceName: String) {
        val resId = context.resources.getIdentifier(resourceName, "raw", context.packageName)
        if (resId != 0) {
            playVoice(context, resId)
        }
    }

    /**
     * Stop currently playing voice line
     */
    fun stopVoice() {
        voicePlayer?.apply {
            if (isPlaying) {
                stop()
            }
            release()
        }
        voicePlayer = null
    }

    /**
     * Pause voice playback
     */
    fun pauseVoice() {
        voicePlayer?.apply {
            if (isPlaying) {
                pause()
            }
        }
    }

    /**
     * Resume voice playback
     */
    fun resumeVoice() {
        voicePlayer?.apply {
            if (!isPlaying) {
                start()
            }
        }
    }

    /**
     * Set voice volume (0.0 to 1.0)
     */
    fun setVolume(volume: Float) {
        voiceVolume = volume.coerceIn(0f, 1f)
        voicePlayer?.setVolume(voiceVolume, voiceVolume)
    }

    /**
     * Enable or disable voice playback
     */
    fun setEnabled(enabled: Boolean) {
        isVoiceEnabled = enabled
        if (!enabled) {
            stopVoice()
        }
    }

    /**
     * Check if voice is currently playing
     */
    fun isPlaying(): Boolean {
        return voicePlayer?.isPlaying == true
    }

    /**
     * Apply voice settings from SharedPreferences
     */
    fun applySettings(context: Context) {
        val prefs = context.getSharedPreferences("BaoBaoPrefs", Context.MODE_PRIVATE)
        voiceVolume = prefs.getFloat("voice_volume", 0.8f)
        isVoiceEnabled = prefs.getBoolean("voice_enabled", true)
        voicePlayer?.setVolume(voiceVolume, voiceVolume)
    }

    // ========== SIMPLE FEATURE VOICE LINES ==========

    /**
     * Get audio resource ID for sign-up scripts (1-5)
     */
    fun getSignupAudioId(context: Context, index: Int): Int {
        val name = "a_%02d".format(index.coerceIn(1, 5))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for login scripts (1-5)
     */
    fun getLoginAudioId(context: Context, index: Int): Int {
        val name = "b_%02d".format(index.coerceIn(1, 5))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for shop scripts (1-5)
     */
    fun getShopAudioId(context: Context, index: Int): Int {
        val name = "c_%02d".format(index.coerceIn(1, 5))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for settings scripts (1-5)
     */
    fun getSettingsAudioId(context: Context, index: Int): Int {
        val name = "d_%02d".format(index.coerceIn(1, 5))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for self-care scripts (1-10)
     */
    fun getSelfCareAudioId(context: Context, index: Int): Int {
        val name = "e_%02d".format(index.coerceIn(1, 10))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for affirmation scripts (1-10)
     */
    fun getAffirmationAudioId(context: Context, index: Int): Int {
        val name = "f_%02d".format(index.coerceIn(1, 10))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for joke scripts (1-10)
     */
    fun getJokeAudioId(context: Context, index: Int): Int {
        val name = "g_%02d".format(index.coerceIn(1, 10))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for claw machine scripts (1-5)
     */
    fun getClawMachineAudioId(context: Context, index: Int): Int {
        val name = "h_%02d".format(index.coerceIn(1, 5))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Get audio resource ID for goodbye scripts (1-5)
     */
    fun getGoodbyeAudioId(context: Context, index: Int): Int {
        val name = "i_%02d".format(index.coerceIn(1, 5))
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    // ========== MOOD CONVERSATION VOICE LINES ==========

    /**
     * Mapping of conversation node IDs to audio file numbers
     */
    private val happyNodeToAudioIndex = mapOf(
        "happy_start" to 1,
        "happy_good_thing" to 2,
        "happy_overall" to 3,
        "happy_achievement" to 4,
        "happy_celebrate_joke" to 5,
        "happy_savor" to 6,
        "happy_fun_activity" to 7,
        "happy_feels_amazing" to 8,
        "happy_proud" to 9,
        "happy_whats_next" to 10,
        "happy_loop" to 11
    )

    private val sadNodeToAudioIndex = mapOf(
        "sad_start" to 1,
        "sad_talk" to 2,
        "sad_company" to 3,
        "sad_unsure" to 4,
        "sad_hurt" to 5,
        "sad_general_down" to 6,
        "sad_sit_together" to 7,
        "sad_distraction" to 8,
        "sad_comfort" to 9,
        "sad_feel_better" to 10,
        "sad_deep_breath" to 11,
        "sad_self_care" to 12,
        "sad_playful" to 13,
        "sad_trying" to 14,
        "sad_still_struggling" to 15,
        "sad_loop" to 16
    )

    private val anxiousNodeToAudioIndex = mapOf(
        "anxious_start" to 1,
        "anxious_talk" to 2,
        "anxious_strategies" to 3,
        "anxious_overwhelming" to 4,
        "anxious_future" to 5,
        "anxious_overthinking" to 6,
        "anxious_helped" to 7,
        "anxious_still_anxious" to 8,
        "anxious_focus" to 9,
        "anxious_dont_know" to 10,
        "anxious_grounding" to 11,
        "anxious_wont_stop" to 12,
        "anxious_distraction" to 13,
        "anxious_keep_talking" to 14,
        "anxious_loop" to 15
    )

    private val tiredNodeToAudioIndex = mapOf(
        "tired_start" to 1,
        "tired_physical" to 2,
        "tired_emotional" to 3,
        "tired_both" to 4,
        "tired_no_sleep" to 5,
        "tired_too_much" to 6,
        "tired_rest_feelings" to 7,
        "tired_overwhelmed" to 8,
        "tired_be_here" to 9,
        "tired_gentle" to 10,
        "tired_try_sleep" to 11,
        "tired_tried_everything" to 12,
        "tired_guilty" to 13,
        "tired_something_light" to 14,
        "tired_just_talk" to 15,
        "tired_loop" to 16
    )

    private val okayNodeToAudioIndex = mapOf(
        "okay_start" to 1,
        "okay_chill" to 2,
        "okay_brighten" to 3,
        "okay_checking" to 4,
        "okay_hang" to 5,
        "okay_chat" to 6,
        "okay_fun" to 7,
        "okay_uplifting" to 8,
        "okay_steady" to 9,
        "okay_mixed" to 10,
        "okay_joke" to 11,
        "okay_more_affirmations" to 12,
        "okay_loop" to 13
    )

    private val interventionNodeToAudioIndex = mapOf(
        "intervention_start" to 1,
        "intervention_managing" to 2,
        "intervention_hard" to 3,
        "intervention_more" to 4,
        "intervention_resources" to 5,
        "intervention_later" to 6,
        "intervention_not_ready" to 7,
        "intervention_complete" to 8
    )

    /**
     * Get audio resource ID for a mood conversation node
     */
    fun getMoodAudioId(context: Context, nodeId: String, mood: String): Int {
        val index = when (mood.lowercase()) {
            "happy" -> happyNodeToAudioIndex[nodeId]
            "sad" -> sadNodeToAudioIndex[nodeId]
            "anxious" -> anxiousNodeToAudioIndex[nodeId]
            "tired" -> tiredNodeToAudioIndex[nodeId]
            "okay" -> okayNodeToAudioIndex[nodeId]
            "intervention" -> interventionNodeToAudioIndex[nodeId]
            else -> null
        } ?: return 0

        val prefix = when (mood.lowercase()) {
            "happy" -> "h_happy"
            "sad" -> "s_sad"
            "anxious" -> "x_anxious"
            "tired" -> "t_tired"
            "okay" -> "o_okay"
            "intervention" -> "int"
            else -> return 0
        }

        val name = "${prefix}_%02d".format(index)
        return context.resources.getIdentifier(name, "raw", context.packageName)
    }

    /**
     * Play voice for a conversation node
     */
    fun playNodeVoice(context: Context, nodeId: String, mood: String) {
        val resId = getMoodAudioId(context, nodeId, mood)
        if (resId != 0) {
            playVoice(context, resId)
        }
    }
}

