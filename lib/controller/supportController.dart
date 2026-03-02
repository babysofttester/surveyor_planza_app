import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/core/storage/token_services.dart';
import 'package:surveyor_app_planzaa/modal/service_project_response_model.dart';
import 'package:surveyor_app_planzaa/modal/support_response_model.dart';

class SupportController extends GetxController {
  final TickerProvider tickerProvider;

  SupportController(this.tickerProvider);

  TextEditingController descriptionController = TextEditingController();

  String selectedProjectId = "";
  String selectedJobId = "";
  String selectedCategory = "";
  String selectedStatus = "completed";

  // List<dynamic> projectList = [];

  List<ProjectItem> projectList = [];
  bool isProjectLoading = false;

  String? authToken;

  @override
  void onInit() {
    fetchSupportProjects();   
    super.onInit();
  }


 Future<void> fetchSupportProjects() async {
  isProjectLoading = true;
  update();

  authToken = await TokenService.getToken(); 

  Map<String, String> body = {
    "status": selectedStatus,
  };

  callWebApi(
    tickerProvider,
    ApiEndpoints.supportProjects,
    body,
    token: authToken,
    onResponse: (response) {
      final decoded = jsonDecode(response.body);

      SupportProjectResponseModel model =
          SupportProjectResponseModel.fromJson(decoded);

      if (model.status == "success") {
        projectList = model.data?.result ?? [];

     
        selectedProjectId = "";
        selectedJobId = "";
      }

      isProjectLoading = false;
      update();
    },
    onError: (error) {
      isProjectLoading = false;
      update();
    },
  );
}
  Future<void> submitSupport() async {
    if (selectedProjectId.isEmpty) {
        Utils.showToast("Error: Please select project");
      //Get.snackbar("Error: ${selectedProjectId.isEmpty}");
      return;
    }

    if (selectedCategory.isEmpty) {
       Utils.showToast("Error: Please select category");
      //Get.snackbar("Error", "Please select category");
      return;
    }
 
    if (descriptionController.text.trim().isEmpty) {
       Utils.showToast("Error: Please enter message");
      //Get.snackbar("Error", "Please enter message");
      return;  
    }

    authToken = await TokenService.getToken();

    Map<String, String> data = {
      "project_id": selectedProjectId,
      "category": selectedCategory,
      "message": descriptionController.text.trim(),
    }; 

    callWebApi(
      tickerProvider,
      ApiEndpoints.support,
      data,
      token: authToken,
      onResponse: (response) {
        final decoded = jsonDecode(response.body);

        SupportResponseModel model =
            SupportResponseModel.fromJson(decoded);

        if (model.status == "success") {
          Utils.showToast("Support Submitted Successfully");

          selectedCategory = "";
          selectedProjectId = "";
          descriptionController.clear();
          Get.back();

          update();
        } else {
          Utils.showToast(model.message ?? "Error");
        }
      },
      onError: (error) {
        Utils.print(error.toString());
      },
    );
  }
}