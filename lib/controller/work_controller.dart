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
import 'package:surveyor_app_planzaa/controller/dashboard_controller.dart';
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
    // _connectivitySubscription = Connectivity()
    //     .onConnectivityChanged
    //     .listen((List<ConnectivityResult> results) {
    //   final isOnline = results.any((r) => r != ConnectivityResult.none);
    //   if (isOnline) {
    //     _autoSyncOfflineQueue();
    //   }
    // });
  }

  @override
  void onClose() {
   // _connectivitySubscription?.cancel();
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
  update();
  await _refreshPendingCount();

  

  if (Get.isRegistered<DashboardController>()) {
    final dc = Get.find<DashboardController>();
    dc.markAsPendingSync(bookingNo);
  
  }

_clearForm();
  Get.back(); 
  return;
}
   
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
  
if (Get.isRegistered<DashboardController>()) {
  final dc = Get.find<DashboardController>();
  dc.removeJobLocally(bookingNo, int.tryParse(projectId)?? 0);
}


  await Future.delayed(const Duration(milliseconds: 500));
    

  if (Get.isRegistered<WorkHistoryController>()) {
    Get.find<WorkHistoryController>().fetchWorkHistory();
  }
  if (Get.isRegistered<EarningController>()) {
    Get.find<EarningController>().fetchEarnings();
  }

   _clearForm();
  isLoading.value = false;
  update();
  

  
  Get.back(); 
  await Future.delayed(const Duration(milliseconds: 200));
  onTabChange?.call(1);
  return;
 
//   _clearForm();
// await _flushOfflineWorkQueue(token);
// Get.back();
// // Small delay to let Get.back() complete before tab switch
// await Future.delayed(const Duration(milliseconds: 100));
// onTabChange?.call(1); 
} else {
            
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
              isLoading.value = false;
            update();
            await _refreshPendingCount();


          if (Get.isRegistered<DashboardController>()) {
  final dc = Get.find<DashboardController>();
 dc.removeJobLocally(bookingNo, int.tryParse(projectId)?? 0);
}

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


  Future<bool> _submitOfflineItem(
      Map<String, dynamic> item, String token) async {
    try {
      final List<String> imagePaths =
          List<String>.from(item['image_paths'] ?? []);

     
      final existingPaths =
          imagePaths.where((p) => File(p).existsSync()).toList();

  
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


