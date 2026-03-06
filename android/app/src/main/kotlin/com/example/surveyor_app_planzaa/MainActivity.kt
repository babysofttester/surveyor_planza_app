package com.example.surveyor_app_planzaa

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Must match the channel name used in your Flutter code
    private val CHANNEL = "com.surveyor_app_planzaa/location"

    private val connectivityReceiver = ConnectivityReceiver()
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {

                // Flutter calls this when Switch is turned ON
                "startLocationService" -> {
                    val token = call.argument<String>("auth_token") ?: ""
                    if (hasLocationPermission()) {
                        startLocationService(token)
                        result.success("started")
                    } else {
                        requestLocationPermissions()
                        result.error("PERMISSION_DENIED", "Location permission not granted", null)
                    }
                }

                // Flutter calls this when Switch is turned OFF
                "stopLocationService" -> {
                    stopLocationService()
                    result.success("stopped")
                }

                // Flutter can check how many items are waiting to sync
                "getPendingCount" -> {
                    val count = OfflineQueueManager(this).pendingCount()
                    result.success(count)
                }

                // Flutter can manually trigger a sync attempt
                "syncNow" -> {
                    val syncIntent = Intent(this, SyncWorkerService::class.java)
                    startService(syncIntent)
                    result.success("sync_started")
                }
                
                "enqueueWork" -> {
    val payload = call.argument<String>("payload") ?: ""
    if (payload.isNotBlank()) {
        OfflineQueueManager(this).enqueueWork(payload)
        result.success("work_queued")
    } else {
        result.error("INVALID", "Empty payload", null)
    }
}

"dequeueAllWork" -> {
    val items = OfflineQueueManager(this).dequeueAllWork()
    result.success(items)   // returns List<String> to Flutter
}

"getPendingWorkCount" -> {
    val count = OfflineQueueManager(this).pendingWorkCount()
    result.success(count)
}

"clearAllWork" -> {
    OfflineQueueManager(this).clearAllWork()
    result.success("cleared")
}

                else -> result.notImplemented()
            }
        }
    }

    private fun startLocationService(authToken: String) {
        // Save token so SyncWorkerService can access it too
        getSharedPreferences("flutter_prefs", Context.MODE_PRIVATE)
            .edit()
            .putString("auth_token", authToken)
            .apply()

        val serviceIntent = Intent(this, LocationService::class.java).apply {
            action = LocationService.ACTION_START
            putExtra("auth_token", authToken)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }

        // Register connectivity receiver to auto-sync offline data
        val filter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        registerReceiver(connectivityReceiver, filter)
    }

    private fun stopLocationService() {
        val serviceIntent = Intent(this, LocationService::class.java).apply {
            action = LocationService.ACTION_STOP
        }
        startService(serviceIntent)

        try {
            unregisterReceiver(connectivityReceiver)
        } catch (e: IllegalArgumentException) {
            // Already unregistered, ignore
        }
    }

    private fun hasLocationPermission(): Boolean {
        val fine = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val background = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContextCompat.checkSelfPermission(
                this, Manifest.permission.ACCESS_BACKGROUND_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        } else true

        return fine && background
    }

    private fun requestLocationPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            permissions.add(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
        }
        ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 100)
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(connectivityReceiver)
        } catch (e: IllegalArgumentException) { /* already unregistered */ }
        super.onDestroy()
    }
}