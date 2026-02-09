package com.example.baobao.optimization

import android.os.Handler
import android.os.Looper
import android.util.Log

/**
 * Memory Optimization Manager
 * Handles cleanup of handlers, callbacks, and prevents memory leaks
 */
object MemoryOptimizer {

    private const val TAG = "MemoryOptimizer"

    /**
     * Clean up all callbacks and messages from a handler
     * This prevents memory leaks from pending runnables
     */
    fun cleanupHandler(handler: Handler) {
        try {
            handler.removeCallbacksAndMessages(null)
            Log.d(TAG, "Handler cleanup successful")
        } catch (e: Exception) {
            Log.e(TAG, "Error cleaning up handler: ${e.message}", e)
        }
    }

    /**
     * Clean up specific runnable from handler
     */
    fun removeCallback(handler: Handler, runnable: Runnable) {
        try {
            handler.removeCallbacks(runnable)
        } catch (e: Exception) {
            Log.e(TAG, "Error removing callback: ${e.message}", e)
        }
    }

    /**
     * Safely post a delayed action with null checks
     */
    fun postDelayed(handler: Handler?, runnable: Runnable?, delayMs: Long): Boolean {
        return try {
            if (handler != null && runnable != null) {
                handler.postDelayed(runnable, delayMs)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error posting delayed: ${e.message}", e)
            false
        }
    }

    /**
     * Check if running on main thread
     */
    fun isMainThread(): Boolean {
        return Looper.myLooper() == Looper.getMainLooper()
    }

    /**
     * Force garbage collection (use sparingly)
     */
    fun forceGC() {
        try {
            System.gc()
            System.runFinalization()
            Log.d(TAG, "Forced garbage collection")
        } catch (e: Exception) {
            Log.e(TAG, "Error forcing GC: ${e.message}", e)
        }
    }
}

