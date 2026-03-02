import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/wrokHistory_response_model.dart';
// import 'your_model_path/work_history_response_model.dart';
// import 'your_shared_prefs/session_manager.dart'; // for getting token

class WorkHistoryController extends GetxController {
    final TickerProvider tickerProvider;
   
  WorkHistoryController(this.tickerProvider);
  var isLoading = false.obs;
  var workList = <Works>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkHistory();
  }
   Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString(Constants.AUTH_TOKEN);
  }
  String? authToken;


Future<void> fetchWorkHistory() async {
 tickerProvider;
  errorMessage('');

  await loadToken();    
  final token = authToken;

  if (token == null || token.isEmpty) {
    Utils.showToast("User not logged in");
    isLoading(false);
    return;
  }

  callWebApiGet(
    tickerProvider,
    ApiEndpoints.workHistory,
    onResponse: (http.Response response) async {
      try {
        var responseJson = jsonDecode(response.body);

        if (response.statusCode == 200 &&
            responseJson['status'] == "success") {

          WorkHistoryResponseModel model =
              WorkHistoryResponseModel.fromJson(responseJson);

          workList.assignAll(model.data?.works ?? []);

        } else {
          errorMessage(
              responseJson['message'] ?? "Failed to load work history");
        }

      } catch (e) {
        errorMessage("Parsing error: $e");
      }

      isLoading(false);  
    },
    token: token,
  );
}

}
