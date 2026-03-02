import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/core/storage/token_services.dart';
import 'package:surveyor_app_planzaa/modal/profile_response_model.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';



class ProfileController extends GetxController {
  final TickerProvider _tickerProvider;
  Rx<ProfileResponseModel> profileResponseModel = ProfileResponseModel().obs;

  ProfileController(this._tickerProvider);

  File? profileImageFile;
  Surveyor? surveyor;

  late SharedPreferences prefs;
  String? authToken;  

  @override
  Future<void> onInit() async {
    super.onInit();

    prefs = await SharedPreferences.getInstance();
     authToken = prefs.getString(Constants.AUTH_TOKEN);

    print("PROFILE TOKEN: $authToken");

// fetchProfile(); 
if (authToken != null && authToken!.isNotEmpty) {
  fetchProfile();
} else {
  Utils.showToast("Session expired. Please login again");
  Get.offAll(() => const LoginPage());
}

  }

    final RxnString selectedState = RxnString();
  final RxnString selectedCity = RxnString();


  // ✅ FETCH PROFILE
  void fetchProfile() {
    callWebApiGet(
      _tickerProvider,
      ApiEndpoints.getProfile,
      onResponse: (http.Response response) async {
        var responseJson = jsonDecode(response.body);

        try {
           profileResponseModel.value =
            ProfileResponseModel.fromJson(responseJson);

        if (profileResponseModel.value.status == "success") {
          // profileResponseModel.value = model;
          surveyor = profileResponseModel.value.data?.surveyor;
          selectedState.value = surveyor?.state;
          selectedCity.value = surveyor?.city;
          print("AVATAR URL: ${surveyor?.avatar}");
          print("PROFILE TOKEN FROM PREFS: $authToken");
          

          update(); 
        } else {
          Utils.showToast(profileResponseModel.value.message.toString());
        }
         
        } catch (e) {
          Utils.print(e.toString());
        }
      },
      token: authToken ?? "",   
    ); 
  }

 
 
  // ✅ UPDATE PROFILE
Future<void> updateProfile({
  required String name,
  required String email,
  File? image,
}) async {
  final userId = await TokenService.getUserId();

  if (userId == null) {
      Utils.showToast("Error: User ID missing");
    // Get.snackbar("Error", "User ID missing");
    return;
  } 
  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse(ApiEndpoints.updateProfile),
    ); 

    request.headers['Authorization'] = 'Bearer $authToken';

    request.fields['id'] = userId;
    request.fields['name'] = name;
    request.fields['email'] = email;

    
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          image.path,
        ),
      );
    }

   var response = await request.send();
   var responseData = await response.stream.bytesToString();
   var jsonResponse = jsonDecode(responseData);


if (jsonResponse["status"] == "success") {
  Utils.showToast("Profile Updated Successfully"); 
  fetchProfile(); 
  Get.back();
} else {
  Utils.showToast(jsonResponse["message"]);
}



  } catch (e) {
    Utils.print(e.toString());
  }
}  

}



