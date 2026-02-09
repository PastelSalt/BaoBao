package com.example.baobao.optimization

import android.util.Log

/**
 * Performance Monitor
 * Tracks and logs performance metrics
 */
object PerformanceMonitor {

    private const val TAG = "PerformanceMonitor"
    private val timingMap = mutableMapOf<String, Long>()

    /**
     * Start timing an operation
     */
    fun startTiming(operationName: String) {
        timingMap[operationName] = System.currentTimeMillis()
    }

    /**
     * End timing and log the duration
     */
    fun endTiming(operationName: String): Long {
        val startTime = timingMap[operationName] ?: return 0L
        val duration = System.currentTimeMillis() - startTime
        timingMap.remove(operationName)

        if (duration > 100) {
            Log.w(TAG, "$operationName took ${duration}ms (slow)")
        } else {
            Log.d(TAG, "$operationName took ${duration}ms")
        }

        return duration
    }

    /**
     * Log memory usage
     */
    fun logMemoryUsage(context: String = "") {
        val runtime = Runtime.getRuntime()
        val usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024
        val maxMemory = runtime.maxMemory() / 1024 / 1024
        val percentage = (usedMemory.toFloat() / maxMemory.toFloat() * 100).toInt()

        Log.d(TAG, "$context Memory: ${usedMemory}MB / ${maxMemory}MB ($percentage%)")

        if (percentage > 80) {
            Log.w(TAG, "High memory usage detected: $percentage%")
        }
    }

    /**
     * Measure execution time of a block
     */
    inline fun <T> measure(operationName: String, block: () -> T): T {
        startTiming(operationName)
        val result = block()
        endTiming(operationName)
        return result
    }
}

