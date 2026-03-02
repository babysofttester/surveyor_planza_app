import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/earning_response_model.dart';

class EarningController extends GetxController {
   final TickerProvider _tickerProvider;


  EarningController(this._tickerProvider);

  
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var paidList = <PaidData>[].obs;
  var unpaidList = <UnpaidPayments>[].obs;
  var totalEarnings = '0.00'.obs;
  var totalDues = '0.00'.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
  }

    Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString(Constants.AUTH_TOKEN);
  }
  String? authToken;


 Future<void> fetchEarnings() async {
  isLoading(true);
  errorMessage('');


 await loadToken();    
  final token = authToken;
   print("EARNING TOKEN: $token");

  if (token == null || token.isEmpty) {
    Utils.showToast("User not logged in");
    isLoading(false);
    return;
  }

  callWebApiGet(
    _tickerProvider, 
    ApiEndpoints.earnings,
    onResponse: (http.Response response) async {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      var responseJson = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseJson['status'] == "success") {

        final model = EarningResponseModel.fromJson(responseJson);
        final earnings = model.data?.earnings;

        if (earnings != null) {
          paidList.assignAll(earnings.paidData ?? []);
          unpaidList.assignAll(earnings.unpaidPayments ?? []);
          totalEarnings.value = earnings.totalEarnings ?? '0.00';
          totalDues.value = earnings.totaldues ?? '0.00';
        }

      } else {
        errorMessage(responseJson['message'] ?? "Failed to load earnings");
        Utils.showToast(errorMessage.value);
      }

      isLoading(false);
    }, 
    token: token,
  );
}

}