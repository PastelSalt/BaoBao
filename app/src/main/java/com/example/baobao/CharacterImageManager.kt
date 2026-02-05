package com.example.baobao

import android.content.Context
import androidx.annotation.DrawableRes

/**
 * Manages BaoBao character images based on outfit and emotion
 * Supports multiple outfits with different emotional expressions
 */
object CharacterImageManager {

    // Current selected outfit (default is outfit1)
    private var currentOutfit = "outfit1"

    /**
     * Available emotions for the character
     */
    enum class Emotion {
        HAPPY,
        HELLO,
        SAD,
        TIRED,
        ANXIOUS,  // For future use
        OKAY,     // For future use
        DEFAULT   // Fallback
    }

    /**
     * Set the current outfit
     * @param outfitName Name of the outfit (e.g., "outfit1", "outfit2")
     */
    fun setOutfit(outfitName: String) {
        currentOutfit = outfitName
    }

    /**
     * Get the current outfit name
     */
    fun getCurrentOutfit(): String = currentOutfit

    /**
     * Get character image resource for a specific emotion
     * @param emotion The emotion to display
     * @param outfit Optional outfit override. If null, uses current outfit
     * @return Drawable resource ID
     */
    @DrawableRes
    fun getCharacterImage(emotion: Emotion, outfit: String? = null): Int {
        val selectedOutfit = outfit ?: currentOutfit

        return when (selectedOutfit) {
            "outfit1" -> getOutfit1Image(emotion)
            "outfit2" -> getOutfit2Image(emotion) // Future outfits
            // Add more outfits here as they become available
            else -> getOutfit1Image(emotion) // Default to outfit1
        }
    }

    /**
     * Get character image based on mood string
     * @param mood Mood string (e.g., "happy", "sad", "tired", "anxious", "okay")
     * @param outfit Optional outfit override
     */
    @DrawableRes
    fun getCharacterImageForMood(mood: String, outfit: String? = null): Int {
        val emotion = when (mood.lowercase()) {
            "happy" -> Emotion.HAPPY
            "sad" -> Emotion.SAD
            "tired" -> Emotion.TIRED
            "anxious" -> Emotion.ANXIOUS
            "okay" -> Emotion.OKAY
            "hello", "greeting" -> Emotion.HELLO
            else -> Emotion.DEFAULT
        }
        return getCharacterImage(emotion, outfit)
    }

    /**
     * Get greeting/hello image for the character
     */
    @DrawableRes
    fun getHelloImage(outfit: String? = null): Int {
        return getCharacterImage(Emotion.HELLO, outfit)
    }

    /**
     * Get default/neutral image for the character
     */
    @DrawableRes
    fun getDefaultImage(outfit: String? = null): Int {
        return getCharacterImage(Emotion.DEFAULT, outfit)
    }

    // ==================== OUTFIT 1 IMAGES ====================

    private fun getOutfit1Image(emotion: Emotion): Int {
        return when (emotion) {
            Emotion.HAPPY -> R.drawable.mainscreen_outfit1_fullbody_happy
            Emotion.HELLO -> R.drawable.mainscreen_outfit1_fullbody_hello
            Emotion.SAD -> R.drawable.mainscreen_outfit1_fullbody_sad
            Emotion.TIRED -> R.drawable.mainscreen_outfit1_fullbody_tired
            Emotion.ANXIOUS -> R.drawable.mainscreen_outfit1_fullbody_sad // Use sad as fallback
            Emotion.OKAY -> R.drawable.mainscreen_outfit1_fullbody_hello // Use hello as fallback
            Emotion.DEFAULT -> R.drawable.mainscreen_outfit1_fullbody_hello // Default to hello
        }
    }

    // ==================== OUTFIT 2 IMAGES (PLACEHOLDER) ====================

    private fun getOutfit2Image(emotion: Emotion): Int {
        // When outfit2 images are added, update this method
        // For now, fallback to outfit1
        // Expected naming: mainscreen_outfit2_fullbody_happy, etc.
        return when (emotion) {
            Emotion.HAPPY -> R.drawable.mainscreen_outfit1_fullbody_happy // TODO: Replace with outfit2
            Emotion.HELLO -> R.drawable.mainscreen_outfit1_fullbody_hello
            Emotion.SAD -> R.drawable.mainscreen_outfit1_fullbody_sad
            Emotion.TIRED -> R.drawable.mainscreen_outfit1_fullbody_tired
            Emotion.ANXIOUS -> R.drawable.mainscreen_outfit1_fullbody_sad
            Emotion.OKAY -> R.drawable.mainscreen_outfit1_fullbody_hello
            Emotion.DEFAULT -> R.drawable.mainscreen_outfit1_fullbody_hello
        }
    }

    // ==================== UTILITY METHODS ====================

    /**
     * Check if an outfit exists
     * @param outfitName Name of the outfit to check
     * @return true if outfit exists, false otherwise
     */
    fun isOutfitAvailable(outfitName: String): Boolean {
        return outfitName in listOf("outfit1", "outfit2") // Update as more outfits are added
    }

    /**
     * Get list of all available outfits
     */
    fun getAvailableOutfits(): List<String> {
        return listOf("outfit1") // "outfit2", etc. will be added later
    }

    /**
     * Get a list of available emotions for current outfit
     */
    fun getAvailableEmotions(): List<Emotion> {
        // For outfit1, we have: happy, hello, sad, tired
        return when (currentOutfit) {
            "outfit1" -> listOf(Emotion.HAPPY, Emotion.HELLO, Emotion.SAD, Emotion.TIRED)
            else -> listOf(Emotion.DEFAULT)
        }
    }
}
