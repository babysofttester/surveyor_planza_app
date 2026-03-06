package com.example.surveyor_app_planzaa

import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.IBinder
import org.json.JSONObject
import java.io.DataOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

/**
 * Lightweight one-shot service that fires when internet comes back.
 * Flushes the entire offline queue to the server then stops itself.
 */
class SyncWorkerService : Service() {

    private val executor = Executors.newSingleThreadExecutor()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences("flutter_prefs", Context.MODE_PRIVATE)
        val authToken = prefs.getString("auth_token", "") ?: ""

        executor.execute {
            flushQueue(authToken)
            stopSelf()
        }

        return START_NOT_STICKY
    }

    private fun flushQueue(authToken: String) {
        if (!isInternetAvailable()) return

        val queue = OfflineQueueManager(this)
        val pending = queue.dequeueAll()
        if (pending.isEmpty()) return

        val failed = mutableListOf<String>()

        for (item in pending) {
            try {
                val success = postLocation(item, authToken)
                if (!success) failed.add(item)
            } catch (e: Exception) {
                failed.add(item)
            }
        }

        // Put back anything that failed
        failed.forEach { queue.enqueue(it) }
    }

    private fun postLocation(jsonString: String, authToken: String): Boolean {
        return try {
            val payload = JSONObject(jsonString)
            val latitude = payload.getString("latitude")
            val longitude = payload.getString("longitude")

            val boundary = "----FormBoundary${System.currentTimeMillis()}"
            val url = URL("https://planzaa.babysofts.in/surveyor-api/live-location-update")
            val conn = url.openConnection() as HttpURLConnection
            conn.apply {
                requestMethod = "POST"
                setRequestProperty("Content-Type", "multipart/form-data; boundary=$boundary")
                setRequestProperty("Authorization", "Bearer $authToken")
                doOutput = true
                connectTimeout = 15000
                readTimeout = 15000
            }

            // Build multipart form-data body — matches your Postman setup
            val body = StringBuilder()
            body.append("--$boundary\r\n")
            body.append("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n")
            body.append("$latitude\r\n")
            body.append("--$boundary\r\n")
            body.append("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n")
            body.append("$longitude\r\n")
            body.append("--$boundary--\r\n")

            DataOutputStream(conn.outputStream).use { it.writeBytes(body.toString()) }

            val code = conn.responseCode
            conn.disconnect()
            code == HttpURLConnection.HTTP_OK
        } catch (e: Exception) {
            false
        }
    }

    private fun isInternetAvailable(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        executor.shutdown()
        super.onDestroy()
    }
}