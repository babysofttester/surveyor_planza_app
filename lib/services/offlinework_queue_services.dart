

import 'dart:convert';
import 'package:flutter/services.dart';

class OfflineWorkQueueService {
  static const _channel = MethodChannel('com.surveyor_app_planzaa/location');

  /// Save a work submission to the native SharedPreferences queue.
  /// [imagePaths] — list of absolute file paths on device
  static Future<void> enqueue({
    required String projectId,
    required String bookingNo,
    required double length,
    required double breadth,
    required String description,
    required List<String> imagePaths,
  }) async {
    final payload = jsonEncode({
      'project_id':   projectId,
      'booking_no':   bookingNo,
      'length':       length,
      'breadth':      breadth,
      'description':  description,
      'image_paths':  imagePaths,              // local paths, synced later
      'queued_at':    DateTime.now().toIso8601String(),
    });

    await _channel.invokeMethod('enqueueWork', {'payload': payload});
  }

  /// Fetch all pending work items from SharedPreferences.
  /// Returns them as parsed Maps.
  static Future<List<Map<String, dynamic>>> dequeueAll() async {
    final List<dynamic> raw =
        await _channel.invokeMethod('dequeueAllWork') ?? [];

    return raw.map((item) {
      return Map<String, dynamic>.from(jsonDecode(item as String));
    }).toList();
  }

  /// How many work submissions are waiting to sync.
  static Future<int> pendingCount() async {
    final count = await _channel.invokeMethod<int>('getPendingWorkCount');
    return count ?? 0;
  }

  /// Wipe queue (call on logout). 
  static Future<void> clearAll() async {
    await _channel.invokeMethod('clearAllWork');
  }
}