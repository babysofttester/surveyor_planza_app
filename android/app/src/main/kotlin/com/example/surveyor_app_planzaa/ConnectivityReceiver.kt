package com.example.surveyor_app_planzaa

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

/**
 * Broadcast receiver that triggers offline queue sync
 * as soon as internet connectivity is restored.
 *
 * Register in AndroidManifest.xml (see instructions below).
 */
class ConnectivityReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (isInternetAvailable(context)) {
            // Notify Flutter side via a local broadcast or just
            // let the LocationService handle it on next location update.
            // Optionally start a one-shot sync job here:
            val syncIntent = Intent(context, SyncWorkerService::class.java)
            context.startService(syncIntent)
        }
    }

    private fun isInternetAvailable(context: Context): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }
}