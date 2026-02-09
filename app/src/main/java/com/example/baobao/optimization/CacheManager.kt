package com.example.baobao.optimization

import android.content.Context
import android.content.SharedPreferences
import android.util.Log

/**
 * Caching Manager for Performance Optimization
 * Reduces database queries and SharedPreferences reads
 */
object CacheManager {

    private const val TAG = "CacheManager"

    // In-memory cache for frequently accessed data
    private var cachedCurrency: Int? = null
    private var currencyCacheTime: Long = 0
    private const val CACHE_VALIDITY_MS = 2000L // 2 seconds

    private var cachedClawTries: Int? = null
    private var triesCacheTime: Long = 0

    /**
     * Cache currency value with timestamp
     */
    fun cacheCurrency(amount: Int) {
        cachedCurrency = amount
        currencyCacheTime = System.currentTimeMillis()
    }

    /**
     * Get cached currency if valid, null otherwise
     */
    fun getCachedCurrency(): Int? {
        val age = System.currentTimeMillis() - currencyCacheTime
        return if (age < CACHE_VALIDITY_MS) cachedCurrency else null
    }

    /**
     * Invalidate currency cache (call when currency changes)
     */
    fun invalidateCurrencyCache() {
        cachedCurrency = null
        currencyCacheTime = 0
    }

    /**
     * Cache claw machine tries
     */
    fun cacheClawTries(tries: Int) {
        cachedClawTries = tries
        triesCacheTime = System.currentTimeMillis()
    }

    /**
     * Get cached claw tries if valid
     */
    fun getCachedClawTries(): Int? {
        val age = System.currentTimeMillis() - triesCacheTime
        return if (age < CACHE_VALIDITY_MS) cachedClawTries else null
    }

    /**
     * Invalidate claw tries cache
     */
    fun invalidateClawTriesCache() {
        cachedClawTries = null
        triesCacheTime = 0
    }

    /**
     * Clear all caches
     */
    fun clearAll() {
        cachedCurrency = null
        currencyCacheTime = 0
        cachedClawTries = null
        triesCacheTime = 0
        Log.d(TAG, "All caches cleared")
    }
}

