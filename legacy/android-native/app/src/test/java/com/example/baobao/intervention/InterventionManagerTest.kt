package com.example.baobao.intervention

import com.example.baobao.database.UserData
import org.json.JSONArray
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InterventionManagerTest {

    private val hour = 60 * 60 * 1000L
    private val now = System.currentTimeMillis()

    private fun checkIn(user: UserData, vararg moods: String): UserData =
        moods.fold(user) { data, mood -> InterventionManager.recordMoodCheckIn(data, mood, now) }

    @Test
    fun checkInRecordsMoodWeightAndHistory() {
        val user = checkIn(UserData(), "Anxious")

        assertEquals("anxious", user.currentMood)
        assertEquals(2, user.emotionalWeight)
        assertEquals(1, user.consecutiveNegativeCycles)

        val history = JSONArray(user.moodHistory)
        assertEquals(1, history.length())
        val entry = history.getJSONObject(0)
        assertEquals("anxious", entry.getString("mood"))
        assertEquals(now, entry.getLong("timestamp"))
        assertEquals(2, entry.getInt("weight"))
    }

    @Test
    fun singleNegativeCheckInDoesNotTrigger() {
        assertFalse(InterventionManager.shouldTriggerIntervention(checkIn(UserData(), "anxious")))
    }

    @Test
    fun twoAnxiousCheckInsTrigger() {
        val user = checkIn(UserData(), "anxious", "anxious")

        assertEquals(4, user.emotionalWeight)
        assertEquals(2, user.consecutiveNegativeCycles)
        assertTrue(InterventionManager.shouldTriggerIntervention(user))
    }

    @Test
    fun sadCheckInsTriggerOnceWeightReachesThreshold() {
        assertFalse(InterventionManager.shouldTriggerIntervention(checkIn(UserData(), "sad", "tired", "sad")))
        assertTrue(InterventionManager.shouldTriggerIntervention(checkIn(UserData(), "sad", "tired", "sad", "sad")))
    }

    @Test
    fun doesNotRetriggerDuringCooldown() {
        val shown = InterventionManager.markInterventionShown(checkIn(UserData(), "anxious", "anxious"))

        assertFalse(InterventionManager.shouldTriggerIntervention(checkIn(shown, "anxious")))
    }

    @Test
    fun retriggersAfterCooldown() {
        val shown = checkIn(UserData(), "anxious", "anxious")
            .copy(interventionTriggered = true, lastInterventionTime = now - 25 * hour)

        assertTrue(InterventionManager.shouldTriggerIntervention(checkIn(shown, "sad")))
    }

    @Test
    fun happyCheckInLowersWeightAndResetsCounter() {
        val user = checkIn(UserData(), "anxious", "anxious", "happy")

        assertEquals(1, user.emotionalWeight)
        assertEquals(0, user.consecutiveNegativeCycles)
        assertFalse(InterventionManager.shouldTriggerIntervention(user))
    }

    @Test
    fun positiveCheckInClearsInterventionFlagOnceBelowThreshold() {
        val shown = InterventionManager.markInterventionShown(checkIn(UserData(), "anxious", "anxious"))

        assertFalse(checkIn(shown, "okay").interventionTriggered)
    }

    @Test
    fun positiveCheckInKeepsInterventionFlagWhileWeightIsHigh() {
        val shown = InterventionManager.markInterventionShown(UserData(emotionalWeight = 10))

        assertTrue(checkIn(shown, "okay").interventionTriggered)
    }

    @Test
    fun weightStaysWithinBounds() {
        assertEquals(0, checkIn(UserData(), "happy").emotionalWeight)
        assertEquals(10, checkIn(UserData(emotionalWeight = 9), "anxious").emotionalWeight)
    }

    @Test
    fun historyIsCappedAtFiftyEntries() {
        val moods = Array(60) { if (it < 59) "okay" else "sad" }
        val history = JSONArray(checkIn(UserData(), *moods).moodHistory)

        assertEquals(50, history.length())
        assertEquals("sad", history.getJSONObject(49).getString("mood"))
    }

    @Test
    fun unreadableHistoryIsReplaced() {
        val history = JSONArray(checkIn(UserData(moodHistory = "not json"), "sad").moodHistory)

        assertEquals(1, history.length())
    }
}
