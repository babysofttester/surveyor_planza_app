package com.example.surveyor_app_planzaa

import android.content.Context
import android.content.SharedPreferences

/**
 * Manages a persistent queue of location payloads when device is offline.
 * Uses SharedPreferences so data survives app kills and restarts.
 */
class OfflineQueueManager(context: Context) {

    companion object {
        private const val PREFS_NAME = "offline_location_queue"
        private const val KEY_QUEUE = "queue_items"
        private const val KEY_COUNTER = "queue_counter"
        private const val KEY_WORK_QUEUE    = "work_queue_items"  
        private const val SEPARATOR = "|||ITEM|||"
    }

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /**
     * Add a JSON payload string to the offline queue.
     */
    @Synchronized
    fun enqueue(jsonPayload: String) {
        val current = getRawQueue()
        val updated = if (current.isEmpty()) jsonPayload
                      else "$current$SEPARATOR$jsonPayload"
        prefs.edit().putString(KEY_QUEUE, updated).apply()
    }

    /**
     * Get all queued items and clear the queue atomically.
     */
    @Synchronized
    fun dequeueAll(): List<String> {
        val raw = getRawQueue()
        if (raw.isEmpty()) return emptyList()

        // Clear immediately so we don't double-send on retry
        prefs.edit().putString(KEY_QUEUE, "").apply()

        return raw.split(SEPARATOR).filter { it.isNotBlank() }
    }

    /**
     * How many items are waiting to be synced.
     */
    fun pendingCount(): Int {
        val raw = getRawQueue()
        if (raw.isBlank()) return 0
        return raw.split(SEPARATOR).count { it.isNotBlank() }
    }

    /**
     * Wipe everything - use only for testing/logout.
     */
    fun clearAll() {
        prefs.edit().putString(KEY_QUEUE, "").apply()
    }

    private fun getRawQueue(): String =
        prefs.getString(KEY_QUEUE, "") ?: ""


    
    // WORK QUEUE (NEW)
   

    @Synchronized
    fun enqueueWork(jsonPayload: String) {
        val current = getRawWorkQueue()
        val updated = if (current.isEmpty()) jsonPayload
                      else "$current$SEPARATOR$jsonPayload"
        prefs.edit().putString(KEY_WORK_QUEUE, updated).apply()
    }

    @Synchronized
    fun dequeueAllWork(): List<String> {
        val raw = getRawWorkQueue()
        if (raw.isEmpty()) return emptyList()
        prefs.edit().putString(KEY_WORK_QUEUE, "").apply()
        return raw.split(SEPARATOR).filter { it.isNotBlank() }
    }

    fun pendingWorkCount(): Int {
        val raw = getRawWorkQueue()
        if (raw.isBlank()) return 0
        return raw.split(SEPARATOR).count { it.isNotBlank() }
    }

    fun clearAllWork() {
        prefs.edit().putString(KEY_WORK_QUEUE, "").apply()
    }

    private fun getRawWorkQueue(): String =
        prefs.getString(KEY_WORK_QUEUE, "") ?: ""
}