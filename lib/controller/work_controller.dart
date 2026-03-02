import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:surveyor_app_planzaa/pages/workHistory.dart';



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
   // Utils.showToast("Error: ${projectId.isEmpty}");
    return;
  }

  if (selectedImages.isEmpty) {
   Utils.showToast("Error: Please add at least one image");
    //Utils.showToast("Error: ${selectedImages.isEmpty}");
    return;
  }

  if (lengthController.text.trim().isEmpty) {
    //    Utils.showToast("Error: ${lengthController.text.trim().isEmpty}");
    Utils.showToast("Error: Please enter length");
    return;
  }

  if (breadthController.text.trim().isEmpty) {
    //  Utils.showToast("Error: ${breadthController.text.trim().isEmpty}");
    Utils.showToast("Error: Please enter breadth");
    return;
  }

  if (descriptionController.text.trim().isEmpty) {
    // Utils.showToast("Error: ${descriptionController.text.trim().isEmpty}");
    Utils.showToast("Error: Please enter description");
    return;
  }

  final token = authToken;

  if (token == null) {
    // Utils.showToast("Error: ${token == null}");
     Utils.showToast("Error: User not logged in");
    return;
  }

 
  Map<String, dynamic> data = {
    "project_id": projectId,
    "booking_no": bookingNo,
    "length": lengthController.text.trim(),
    "breadth": breadthController.text.trim(),
    "description": descriptionController.text.trim(),
  };

  // Convert images to base64
  for (int i = 0; i < selectedImages.length; i++) {
    File imageFile = File(selectedImages[i].path);
    String fileName = selectedImages[i].name;
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    data["images[$i][file_name]"] = fileName;
    data["images[$i][file_base64]"] = base64Image;
  }

tickerProvider;
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
          //  Utils.showToast(
          //     responseJson['message'] ?? "Work submitted successfully");
          
await Future.delayed(const Duration(milliseconds: 500));


if (Get.isRegistered<WorkHistoryController>()) {
  Get.find<WorkHistoryController>().fetchWorkHistory();
}


  if (Get.isRegistered<EarningController>()) {
    Get.find<EarningController>().fetchEarnings();
  }

Get.back(); 

onTabChange?.call(2);
         
          selectedImages.clear();
          lengthController.clear();
          breadthController.clear();
          descriptionController.clear();
     
        } else {
          Utils.showToast("${responseJson['message']}");
//           Utils.showToast(
// responseJson['message'] ?? "Something went wrong");
        }

      } catch (e) {
        e.printError();
        Utils.print(e.toString());
        Utils.showToast(e.toString());
        // Utils.showToast("Something went wrong. Try again.");
      }

      isLoading.value = false;
      update();
    },
  );
}
  @override
  void onClose() {
    lengthController.dispose();
    breadthController.dispose();
    descriptionController.dispose(); 
    
    super.onClose();
  }
}