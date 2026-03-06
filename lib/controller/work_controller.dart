import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  String projectId = "";
  String bookingNo = "";
  String? acceptedAt;

  @override
  void onInit() {
    super.onInit();
    loadToken();
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

    final token = authToken;
    if (token == null) {
      Utils.showToast("Error: User not logged in");
      return;
    }

    isLoading.value = true;


    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (!isOnline) {
     
      await OfflineWorkQueueService.enqueue(
        projectId: projectId,
        bookingNo: bookingNo,
        length: double.tryParse(lengthController.text.trim()) ?? 0.0,
        breadth: double.tryParse(breadthController.text.trim()) ?? 0.0,
        description: descriptionController.text.trim(),
        imagePaths: selectedImages.map((f) => f.path).toList(),
      );

      isLoading.value = false;

      Get.snackbar(
        "Saved Offline",
        "Work saved locally. It will sync when you're back online.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }


    await _submitToServer(token);
  }

  

  Future<void> _submitToServer(String token) async {
  
    Map<String, dynamic> data = {
      "project_id": projectId,
      "booking_no": bookingNo,
      "length": lengthController.text.trim(),
      "breadth": breadthController.text.trim(),
      "description": descriptionController.text.trim(),
    };

   
    for (int i = 0; i < selectedImages.length; i++) {
      File imageFile = File(selectedImages[i].path);
      String fileName = selectedImages[i].name;
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      data["images[$i][file_name]"] = fileName;
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

            
            if (Get.isRegistered<WorkHistoryController>()) {
              Get.find<WorkHistoryController>().fetchWorkHistory();
            }

            if (Get.isRegistered<EarningController>()) {
              Get.find<EarningController>().fetchEarnings();
            }

           
            selectedImages.clear();
            lengthController.clear();
            breadthController.clear();
            descriptionController.clear();

            
            await _flushOfflineWorkQueue(token);

            Get.back();
            onTabChange?.call(2);
          } else {
            Utils.showToast("${responseJson['message']}");
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

  
  Future<void> _flushOfflineWorkQueue(String token) async {
    final pending = await OfflineWorkQueueService.dequeueAll();
    if (pending.isEmpty) return;

    final failed = <Map<String, dynamic>>[];

    for (final item in pending) {
      final success = await _submitOfflineItem(item, token);
      if (!success) failed.add(item);
    }

   
    for (final item in failed) {
      await OfflineWorkQueueService.enqueue(
        projectId: item['project_id'] ?? '',
        bookingNo: item['booking_no'] ?? '',
        length: (item['length'] as num).toDouble(),
        breadth: (item['breadth'] as num).toDouble(),
        description: item['description'] ?? '',
        imagePaths: List<String>.from(item['image_paths'] ?? []),
      );
    }

    if (failed.isEmpty && pending.isNotEmpty) {
      Get.snackbar(
        "Synced",
        "${pending.length} offline submission(s) uploaded.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }


  Future<bool> _submitOfflineItem(
      Map<String, dynamic> item, String token) async {
    try {
      Map<String, dynamic> data = {
        "project_id": item['project_id'] ?? '',
        "booking_no": item['booking_no'] ?? '',
        "length": item['length'].toString(),
        "breadth": item['breadth'].toString(),
        "description": item['description'] ?? '',
      };

   
      final List<String> imagePaths =
          List<String>.from(item['image_paths'] ?? []);

      for (int i = 0; i < imagePaths.length; i++) {
        final file = File(imagePaths[i]);

   
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        final fileName = imagePaths[i].split('/').last;

        data["images[$i][file_name]"] = fileName;
        data["images[$i][file_base64]"] = base64Image;
      }

      
      final uri = Uri.parse(ApiEndpoints.workUpload);
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      final responseJson = jsonDecode(response.body);
      return response.statusCode == 200 &&
          responseJson['status'] == "success";
    } catch (e) {
      Utils.print("Offline flush error: $e");
      return false;
    }
  }



  @override
  void onClose() {
    lengthController.dispose();
    breadthController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}