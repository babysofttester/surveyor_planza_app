package com.example.surveyor_app_planzaa

import android.content.ContentValues
import android.content.Context
import android.content.SharedPreferences
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

// ──────────────────────────────────────────────
// SQLite helper — only for the WORK queue
// ──────────────────────────────────────────────
private class WorkQueueDbHelper(context: Context) :
    SQLiteOpenHelper(context, "work_queue.db", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS work_queue (
                id      INTEGER PRIMARY KEY AUTOINCREMENT,
                payload TEXT    NOT NULL
            )
            """.trimIndent()
        )
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS work_queue")
        onCreate(db)
    }
}

// ──────────────────────────────────────────────
// OfflineQueueManager
// ──────────────────────────────────────────────
class OfflineQueueManager(context: Context) {

    companion object {
        private const val PREFS_NAME = "offline_location_queue"
        private const val KEY_QUEUE  = "queue_items"
        private const val SEPARATOR  = "|||ITEM|||"
    }

    // ── SharedPreferences stays for LOCATION queue ──
    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    // ── SQLite for WORK queue ──
    private val dbHelper = WorkQueueDbHelper(context)

    // ════════════════════════════════════════════
    // LOCATION QUEUE  (unchanged — SharedPreferences)
    // ════════════════════════════════════════════

    @Synchronized
    fun enqueue(jsonPayload: String) {
        val current = getRawQueue()
        val updated = if (current.isEmpty()) jsonPayload
                      else "$current$SEPARATOR$jsonPayload"
        prefs.edit().putString(KEY_QUEUE, updated).apply()
    }

    @Synchronized
    fun dequeueAll(): List<String> {
        val raw = getRawQueue()
        if (raw.isEmpty()) return emptyList()
        prefs.edit().putString(KEY_QUEUE, "").apply()
        return raw.split(SEPARATOR).filter { it.isNotBlank() }
    }

    fun pendingCount(): Int {
        val raw = getRawQueue()
        if (raw.isBlank()) return 0
        return raw.split(SEPARATOR).count { it.isNotBlank() }
    }

    fun clearAll() {
        prefs.edit().putString(KEY_QUEUE, "").apply()
    }

    private fun getRawQueue(): String =
        prefs.getString(KEY_QUEUE, "") ?: ""

    // ════════════════════════════════════════════
    // WORK QUEUE  (migrated → SQLite / sqflite)
    // ════════════════════════════════════════════

    @Synchronized
    fun enqueueWork(jsonPayload: String) {
        val db = dbHelper.writableDatabase
        val cv = ContentValues().apply { put("payload", jsonPayload) }
        db.insert("work_queue", null, cv)
        // db stays open — SQLiteOpenHelper manages lifecycle
    }

    @Synchronized
    fun dequeueAllWork(): List<String> {
        val db = dbHelper.writableDatabase
        val results = mutableListOf<String>()

        db.beginTransaction()
        try {
            val cursor = db.query(
                "work_queue",
                arrayOf("id", "payload"),
                null, null, null, null,
                "id ASC"
            )
            cursor.use {
                while (it.moveToNext()) {
                    results.add(it.getString(it.getColumnIndexOrThrow("payload")))
                }
            }
            db.delete("work_queue", null, null)
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }

        return results
    }

    fun pendingWorkCount(): Int {
        val db = dbHelper.readableDatabase
        val cursor = db.rawQuery("SELECT COUNT(*) FROM work_queue", null)
        return cursor.use {
            if (it.moveToFirst()) it.getInt(0) else 0
        }
    }

    fun clearAllWork() {
        dbHelper.writableDatabase.delete("work_queue", null, null)
    }
}