import 'dart:convert';

import 'package:get/get.dart';          
import 'package:http/http.dart' as http; 
import 'package:surveyor_app_planzaa/common/load_manager.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/core/storage/token_services.dart';
  
class StateCityController extends GetxController {
  


  StateCityController(); 

 
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
    null,
    ApiEndpoints.getStates,
       showLoader: false, 
      hideLoader: false,
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
   null,
    ApiEndpoints.getCities,
    data,
       showLoader: false, 
      hideLoader: false,
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