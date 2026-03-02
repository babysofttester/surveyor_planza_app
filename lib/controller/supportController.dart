import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/core/storage/token_services.dart';
import 'package:surveyor_app_planzaa/modal/support_response_model.dart';

class SupportController extends GetxController {
  final TickerProvider tickerProvider;

  SupportController(this.tickerProvider);

  TextEditingController descriptionController = TextEditingController();

String selectedProjectId = "";
String selectedCategory = "";

  List<ProjectModel> projectList = [];
  bool isProjectLoading = false;

  // bool isLoading = false;
  String? authToken;

  @override
void onInit() {
  //fetchProjects();
  super.onInit();
}

  Future<void> submitSupport() async { 

    if (selectedProjectId.isEmpty) {
      Get.snackbar("Error", "Please select project");
      return;
    }

    if (selectedCategory.isEmpty) {
      Get.snackbar("Error", "Please select category");
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter message");
      return;
    }

    tickerProvider;
    update();

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
      onResponse: (http.Response response) {
        try {
          final decoded = jsonDecode(response.body);

          SupportResponseModel model =
              SupportResponseModel.fromJson(decoded);

          if (model.status == "success") {
              Utils.showToast("Support Submitted Successfully");
            Get.snackbar("Success", model.message ?? "Submitted");

            selectedCategory = "";
            selectedProjectId = "";
            descriptionController.clear();
            update();
          } else {
              Utils.showToast(model.message.toString());
           // Get.snackbar("Error", model.message ?? "Something went wrong");
          }
        } catch (e) {
          Utils.print(e.toString());
        }

        tickerProvider;
        update();
      },
      onError: (error) {
       tickerProvider;
        update();
        Utils.print(error.toString());
      },
    );
  }




// Future<void> fetchProjects() async {
//   isProjectLoading = true;
//   update();

//   authToken = await TokenService.getToken();

//   if (authToken == null || authToken!.isEmpty) {
//     isProjectLoading = false;
//     update();
//     Get.snackbar("Error", "Token not found");
//     return;
//   }

//   callWebApiGet(
//     tickerProvider,
//     ApiEndpoints.projects,
//     token: authToken!,
//     onResponse: (response) {
//       final decoded = jsonDecode(response.body);

//       if (decoded['status'] == "success") {

//         List data = decoded['data']['result'];

//         projectList =
//             data.map((e) => ProjectModel.fromJson(e)).toList();
//       }

//       isProjectLoading = false;
//       update();
//     },
//     onError: (error) {
//       isProjectLoading = false;
//       update();
//     },
//   );
// }


}

