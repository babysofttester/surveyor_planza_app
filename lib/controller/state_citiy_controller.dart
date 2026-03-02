import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart' as http;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/dynamic_extensions.dart';
import 'package:surveyor_app_planzaa/common/load_manager.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/core/storage/token_services.dart';

class StateCityController extends GetxController {
  final TickerProvider _tickerProvider;


  StateCityController(this._tickerProvider);

 
  final RxList<String> cities = <String>[].obs;
  final RxList<String> states = <String>[].obs;


  final RxnString selectedCity = RxnString();
  final RxnString selectedState = RxnString();


////////////////////////states///////////////////////////
Future<void> fetchStates() async {
  
  final token = await TokenService.getToken();
print("STATE TOKEN: $token");


  if (token == null || token.isEmpty) {
    Utils.showToast("Error: User not logged in");
   // Get.snackbar("Error", "User not logged in");
    return;
  }
  callWebApiGet( 
    _tickerProvider,
    ApiEndpoints.getStates,
    onResponse: (http.Response response) async {

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      var responseJson = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseJson['status'] == "success") {

        states.assignAll(
          List<String>.from(responseJson['data']['states']),
        );

      } else {
        Utils.showToast(
            responseJson['message'] ?? "Failed to load states");
      }
    },
    token: token,
  );
}


//////////////////cities///////////////////////////
Future<void> fetchCities(String state) async {
  final token = await TokenService.getToken();

  if (token == null) {
     Utils.showToast("Error: User not logged in");
    // Get.snackbar("Error", "User not logged in");
    return;
  }

  cities.clear();
  selectedCity.value = null;

  Map<String, String> data = {
    "state": state,
  };

  callWebApi(
    _tickerProvider,
    ApiEndpoints.getCities,
    data,
    onResponse: (http.Response response) async {
      var responseJson = jsonDecode(response.body);

      try {
        print('response: ${response}');
         print('status: ${responseJson}');
        print('response.body: ${response.body}'); 
        if (responseJson['status'] == "success") {
          cities.assignAll(
            List<String>.from(responseJson['data']['cities']),
          );
        } else {
          Utils.showToast(
              responseJson['message'] ?? "Failed to load cities");
        }
      } catch (e) {
        LoaderManager.hideLoader();
        e.printError();
        Utils.print(e.toString());
      } 
    },
    token: token,
     // token: authToken ?? "", 
   // method: HttpMethod.post, // if required
  );
}

}