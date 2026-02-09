package com.example.baobao.database

import android.content.Context
import android.content.SharedPreferences

/**
 * Manages user session and authentication state
 */
object SessionManager {
    private const val PREF_NAME = "BaoBaoSession"
    private const val KEY_USER_ID = "current_user_id"
    private const val KEY_USERNAME = "current_username"
    private const val KEY_IS_LOGGED_IN = "is_logged_in"
    private const val KEY_IS_GUEST = "is_guest"

    private var currentUserId: Int = -1
    private var currentUsername: String = ""
    private var isGuest: Boolean = false

    /**
     * Initialize session manager with context
     */
    fun init(context: Context) {
        val prefs = getPrefs(context)
        currentUserId = prefs.getInt(KEY_USER_ID, -1)
        currentUsername = prefs.getString(KEY_USERNAME, "") ?: ""
        isGuest = prefs.getBoolean(KEY_IS_GUEST, false)
    }

    /**
     * Login user and save session
     */
    fun login(context: Context, userId: Int, username: String, isGuestAccount: Boolean = false) {
        currentUserId = userId
        currentUsername = username
        isGuest = isGuestAccount

        getPrefs(context).edit().apply {
            putInt(KEY_USER_ID, userId)
            putString(KEY_USERNAME, username)
            putBoolean(KEY_IS_LOGGED_IN, true)
            putBoolean(KEY_IS_GUEST, isGuestAccount)
            apply()
        }
    }

    /**
     * Logout user and clear session
     */
    fun logout(context: Context) {
        currentUserId = -1
        currentUsername = ""
        isGuest = false

        getPrefs(context).edit().apply {
            remove(KEY_USER_ID)
            remove(KEY_USERNAME)
            remove(KEY_IS_GUEST)
            putBoolean(KEY_IS_LOGGED_IN, false)
            apply()
        }
    }

    /**
     * Check if user is logged in
     */
    fun isLoggedIn(context: Context): Boolean {
        return getPrefs(context).getBoolean(KEY_IS_LOGGED_IN, false) && currentUserId != -1
    }

    /**
     * Check if current user is a guest account
     */
    fun isGuestAccount(): Boolean = isGuest

    /**
     * Get current user ID
     */
    fun getCurrentUserId(): Int = currentUserId

    /**
     * Get current username
     */
    fun getCurrentUsername(): String = currentUsername

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }
}

