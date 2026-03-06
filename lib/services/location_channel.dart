// ============================================================
// lib/services/location_channel.dart
// ============================================================

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationChannel {
  static const _channel = MethodChannel('com.surveyor_app_planzaa/location');

  /// Call when user turns the Switch ON
  /// Returns true if started successfully, false if permission denied
  static Future<bool> goOnline() async {
    // ✅ STEP 1: Check & request location permission FIRST
    final granted = await _requestLocationPermission();
    if (!granted) return false;

    // ✅ STEP 2: Check if location service (GPS) is enabled on device
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Opens device location settings so user can turn GPS on
      await Geolocator.openLocationSettings();
      return false;
    }

    // ✅ STEP 3: Start Kotlin service
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      await _channel.invokeMethod('startLocationService', {
        'auth_token': token,
      });
      return true;
    } on PlatformException catch (e) {
      print('Failed to start location service: ${e.message}');
      return false;
    }
  }

  /// Call when user turns the Switch OFF
  static Future<void> goOffline() async {
    try {
      await _channel.invokeMethod('stopLocationService');
    } on PlatformException catch (e) {
      print('Failed to stop location service: ${e.message}');
    }
  }

  /// Returns how many location updates are queued offline
  static Future<int> getPendingCount() async {
    try {
      final count = await _channel.invokeMethod<int>('getPendingCount');
      return count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Manually trigger a sync attempt
  static Future<void> syncNow() async {
    try {
      await _channel.invokeMethod('syncNow');
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // Private: handles all permission cases cleanly
  // ─────────────────────────────────────────────
  static Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // Already granted — nothing to do
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    // Denied but can still ask — show the system dialog
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        return true;
      }
    }

    // Permanently denied — send user to app settings
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return false;
  }
}


