package com.example.surveyor_app_planzaa

import android.app.*
import android.content.Context
import android.content.Intent
import android.location.Location
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.*
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import org.json.JSONObject
import java.io.DataOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

class LocationService : Service() {

    companion object {
        const val CHANNEL_ID = "LocationServiceChannel"
        const val NOTIFICATION_ID = 1
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val LOCATION_INTERVAL_MS = 300_000L  //  10 seconds  300_000L 
    }
 
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private val executor = Executors.newSingleThreadExecutor()
    private lateinit var offlineQueue: OfflineQueueManager
    private var authToken: String = ""

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        offlineQueue = OfflineQueueManager(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                authToken = intent.getStringExtra("auth_token") ?: ""
                startForeground(NOTIFICATION_ID, buildNotification("Surveyor is Online"))
                startLocationUpdates()
            }
            ACTION_STOP -> {
                stopLocationUpdates()
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            LOCATION_INTERVAL_MS
        )
            .setMinUpdateIntervalMillis(LOCATION_INTERVAL_MS)
            .setWaitForAccurateLocation(false)
            .build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                val location = result.lastLocation ?: return
                handleLocationUpdate(location)
            }
        }

        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }

    private fun stopLocationUpdates() {
        if (::locationCallback.isInitialized) {
            fusedLocationClient.removeLocationUpdates(locationCallback)
        }
        stopForeground(STOP_FOREGROUND_REMOVE)
    }
    
    
   


    private fun handleLocationUpdate(location: Location) {
       android.util.Log.d("LocationService", "📍 Location update: lat=${location.latitude}, lng=${location.longitude}, internet=${isInternetAvailable()}")

    val payload = JSONObject().apply {
        put("latitude", location.latitude)
        put("longitude", location.longitude)
        put("timestamp", System.currentTimeMillis())
        put("accuracy", location.accuracy)
    }

        if (isInternetAvailable()) {
            // Try to flush any queued offline data first
            executor.execute { flushOfflineQueue() }
            // Then send current location
            executor.execute { sendLocationToServer(payload) }
        } else {
            // Save to offline queue
            offlineQueue.enqueue(payload.toString())
            updateNotification("Offline - Location saved locally")
        }
    }

    private fun sendLocationToServer(payload: JSONObject, skipQueue: Boolean = false): Boolean {
        return try {
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

            // Build multipart form-data body with latitude and longitude
            val latitude = payload.getString("latitude")
            val longitude = payload.getString("longitude")

            val body = StringBuilder()
            body.append("--$boundary\r\n")
            body.append("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n")
            body.append("$latitude\r\n")
            body.append("--$boundary\r\n")
            body.append("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n")
            body.append("$longitude\r\n")
            body.append("--$boundary--\r\n")

            DataOutputStream(conn.outputStream).use { it.writeBytes(body.toString()) }

            val responseCode = conn.responseCode
            conn.disconnect()

          if (responseCode == HttpURLConnection.HTTP_OK) {
    android.util.Log.d("LocationService", "Location sent to server successfully")
    updateNotification("Online - Location updated ✓")
    true
} else {
    
    android.util.Log.d("LocationService", "Server returned: $responseCode — saved to offline queue")
    if (!skipQueue) offlineQueue.enqueue(payload.toString())
    false
    
}
        } catch (e: Exception) {
            e.printStackTrace()
            if (!skipQueue) offlineQueue.enqueue(payload.toString())
            false
        } 
    }

    private fun flushOfflineQueue() {
        if (!isInternetAvailable()) return

        val pending = offlineQueue.dequeueAll()
        if (pending.isEmpty()) return

        val failedItems = mutableListOf<String>()

        for (item in pending) {
            try {
                val payload = JSONObject(item)
                val success = sendLocationToServer(payload, skipQueue = true) 
                if (!success) failedItems.add(item)
            } catch (e: Exception) {
                failedItems.add(item)
            }
        }

        // Re-enqueue anything that still failed
        failedItems.forEach { offlineQueue.enqueue(it) }

        if (failedItems.isEmpty() && pending.isNotEmpty()) {
            updateNotification("Online - Synced ${pending.size} offline locations")
        }
    }

    private fun isInternetAvailable(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Location Tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Used for surveyor location tracking"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(message: String): Notification {
        val stopIntent = PendingIntent.getService(
            this, 0,
            Intent(this, LocationService::class.java).apply { action = ACTION_STOP },
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Surveyor Active")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_delete, "Go Offline", stopIntent)
            .build()
    }

    private fun updateNotification(message: String) {
        val nm = getSystemService(NotificationManager::class.java)
        nm.notify(NOTIFICATION_ID, buildNotification(message))
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopLocationUpdates()
        executor.shutdown()
        super.onDestroy()
    }
}