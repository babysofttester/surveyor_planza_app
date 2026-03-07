import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/controller/eraning_controller.dart';
import 'package:surveyor_app_planzaa/controller/workHistory_controller.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/services/offlinework_queue_services.dart';

class WorkController extends GetxController {
  final TickerProvider tickerProvider;
  final Function(int)? onTabChange;

  WorkController(this.tickerProvider, {this.onTabChange});

  String? authToken;

  var selectedImages = <XFile>[].obs;
  var lengthController = TextEditingController();
  var breadthController = TextEditingController();
  var descriptionController = TextEditingController();
  var isLoading = false.obs;
  var isSavedOffline = false.obs;
  var pendingOfflineCount = 0.obs;

  String projectId = "";
  String bookingNo = "";
  String? acceptedAt;

  StreamSubscription? _connectivitySubscription;



  @override
  void onInit() {
    super.onInit();
    loadToken();
    _refreshPendingCount();
    // Auto-sync whenever internet comes back
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        _autoSyncOfflineQueue();
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    lengthController.dispose();
    breadthController.dispose();
    descriptionController.dispose();
    super.onClose();
  }



  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString(Constants.AUTH_TOKEN);
  }


  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedImages.addAll(images);
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }


  Future<void> _refreshPendingCount() async {
    pendingOfflineCount.value = await OfflineWorkQueueService.pendingCount();
  }

  Future<void> submitWork() async {
    // Validation
    if (projectId.isEmpty || bookingNo.isEmpty) {
      Utils.showToast("Error: Missing job information");
      return;
    }
    if (selectedImages.isEmpty) {
      Utils.showToast("Error: Please add at least one image");
      return;
    }
    if (lengthController.text.trim().isEmpty) {
      Utils.showToast("Error: Please enter length");
      return;
    }
    if (breadthController.text.trim().isEmpty) {
      Utils.showToast("Error: Please enter breadth");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      Utils.showToast("Error: Please enter description");
      return;
    }

    await loadToken();
    final token = authToken;
    if (token == null || token.isEmpty) {
      Utils.showToast("Error: User not logged in");
      return;
    }

    isLoading.value = true;
    isSavedOffline.value = false;

    final isOnline = await _isInternetAvailable();

    if (!isOnline) {
      //  OFFLINE: save to SQLite 
      await OfflineWorkQueueService.enqueue(
        projectId:   projectId,
        bookingNo:   bookingNo,
        length:      double.tryParse(lengthController.text.trim()) ?? 0.0,
        breadth:     double.tryParse(breadthController.text.trim()) ?? 0.0,
        description: descriptionController.text.trim(),
        imagePaths:  selectedImages.map((f) => f.path).toList(),
      );

      isSavedOffline.value = true;
      isLoading.value = false;
      await _refreshPendingCount();

      Get.snackbar(
        "Saved Offline",
        "No internet. Work saved locally and will sync automatically.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    //  ONLINE: submit to server 
    await _submitToServer(token);
  }

 
  Future<void> _submitToServer(String token) async {
    Map<String, dynamic> data = {
      "project_id":  projectId,
      "booking_no":  bookingNo,
      "length":      lengthController.text.trim(),
      "breadth":     breadthController.text.trim(),
      "description": descriptionController.text.trim(),
    };

    for (int i = 0; i < selectedImages.length; i++) {
      File imageFile = File(selectedImages[i].path);
      String fileName = selectedImages[i].name;
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      data["images[$i][file_name]"]   = fileName;
      data["images[$i][file_base64]"] = base64Image;
    }

    update();

    callWebApi(
      tickerProvider,
      ApiEndpoints.workUpload,
      data,
      token: token,
      onResponse: (http.Response response) async {
        try {
          var responseJson = jsonDecode(response.body);
          Utils.print("Work Upload Response: ${response.body}");

          if (responseJson['status'] == "success") {
            Utils.showToast("${responseJson['message']}");

            await Future.delayed(const Duration(milliseconds: 500));

            // Refresh related controllers
            if (Get.isRegistered<WorkHistoryController>()) {
              Get.find<WorkHistoryController>().fetchWorkHistory();
            }
            if (Get.isRegistered<EarningController>()) {
              Get.find<EarningController>().fetchEarnings();
            }

            // Clear form
            _clearForm();

            // Flush any offline items that were saved before
            await _flushOfflineWorkQueue(token);

            Get.back();
            onTabChange?.call(2);

          } else {
            // Server responded but returned failure — save offline as fallback
            Utils.showToast("${responseJson['message']}");

            await OfflineWorkQueueService.enqueue(
              projectId:   projectId,
              bookingNo:   bookingNo,
              length:      double.tryParse(lengthController.text.trim()) ?? 0.0,
              breadth:     double.tryParse(breadthController.text.trim()) ?? 0.0,
              description: descriptionController.text.trim(),
              imagePaths:  selectedImages.map((f) => f.path).toList(),
            );

            isSavedOffline.value = true;
            await _refreshPendingCount();

            Get.snackbar(
              "Saved Offline",
              "Server error. Work saved locally and will retry automatically.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          e.printError();
          Utils.print(e.toString());
          Utils.showToast(e.toString());
        }

        isLoading.value = false;
        update();
      },
    );
  }

  
  // AUTO SYNC — triggered by connectivity listener


  Future<void> _autoSyncOfflineQueue() async {
    await loadToken();
    final token = authToken;
    if (token == null || token.isEmpty) return;

    final count = await OfflineWorkQueueService.pendingCount();
    if (count == 0) return;

    final isOnline = await _isInternetAvailable();
    if (!isOnline) return;

    await _flushOfflineWorkQueue(token);
  }

  // 
  // FLUSH OFFLINE QUEUE
  // 

  Future<void> _flushOfflineWorkQueue(String token) async {
    final pending = await OfflineWorkQueueService.dequeueAll();
    if (pending.isEmpty) return;

    final failed = <Map<String, dynamic>>[];

    for (final item in pending) {
      final success = await _submitOfflineItem(item, token);
      if (!success) failed.add(item);
    }

    // Re-queue failed items
    for (final item in failed) {
      await OfflineWorkQueueService.enqueue(
        projectId:   item['project_id'] ?? '',
        bookingNo:   item['booking_no'] ?? '',
        length:      (item['length'] as num).toDouble(),
        breadth:     (item['breadth'] as num).toDouble(),
        description: item['description'] ?? '',
        imagePaths:  List<String>.from(item['image_paths'] ?? []),
      );
    }

    await _refreshPendingCount();

    if (failed.isEmpty && pending.isNotEmpty) {
      // Refresh history after successful sync
      if (Get.isRegistered<WorkHistoryController>()) {
        Get.find<WorkHistoryController>().fetchWorkHistory();
      }
      if (Get.isRegistered<EarningController>()) {
        Get.find<EarningController>().fetchEarnings();
      }

      Get.snackbar(
        "Synced",
        "${pending.length} offline submission(s) uploaded successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else if (failed.isNotEmpty) {
      Get.snackbar(
        "Partial Sync",
        "${pending.length - failed.length} synced, ${failed.length} still pending.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  } 

  // 
  // SUBMIT A SINGLE OFFLINE ITEM
  // 

  Future<bool> _submitOfflineItem(
      Map<String, dynamic> item, String token) async {
    try {
      final List<String> imagePaths =
          List<String>.from(item['image_paths'] ?? []);

      // Check if any images still exist on device
      final existingPaths =
          imagePaths.where((p) => File(p).existsSync()).toList();

      // If all images are gone, skip silently (treat as done)
      if (imagePaths.isNotEmpty && existingPaths.isEmpty) {
        Utils.print(
            "Skipping offline item [${item['booking_no']}] — all images deleted from temp storage");
        return true;
      }

      Map<String, dynamic> data = {
        "project_id":  item['project_id'] ?? '',
        "booking_no":  item['booking_no'] ?? '',
        "length":      item['length'].toString(),
        "breadth":     item['breadth'].toString(),
        "description": item['description'] ?? '',
      };

      for (int i = 0; i < existingPaths.length; i++) {
        final bytes    = await File(existingPaths[i]).readAsBytes();
        final base64Image = base64Encode(bytes);
        final fileName = existingPaths[i].split('/').last;

        data["images[$i][file_name]"]   = fileName;
        data["images[$i][file_base64]"] = base64Image;
      }

      final uri = Uri.parse(ApiEndpoints.workUpload);
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      final responseJson = jsonDecode(response.body);
      return response.statusCode == 200 &&
          responseJson['status'] == "success";
    } catch (e) {
      Utils.print("Offline flush error: $e");
      return false;
    }
  }

  // 
  // HELPERS
  // 

  void _clearForm() {
    selectedImages.clear();
    lengthController.clear();
    breadthController.clear();
    descriptionController.clear();
    isSavedOffline.value = false;
  }

  Future<bool> _isInternetAvailable() async {
    final result = await Connectivity().checkConnectivity();
    if (result.every((r) => r == ConnectivityResult.none)) return false;
    try {
      final res = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  } 
}