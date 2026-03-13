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
import 'package:surveyor_app_planzaa/modal/edit_profile_response_model.dart';
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
  // ✅ Controller mein add karo (top pe)
final TextEditingController latController = TextEditingController();
final TextEditingController lngController = TextEditingController();

@override
Future<void> onInit() async {
  super.onInit();
  prefs = await SharedPreferences.getInstance();
  authToken = prefs.getString(Constants.AUTH_TOKEN);

  if (authToken != null && authToken!.isNotEmpty) {
      print("PROFILE TOKEN: $authToken");
    print("FETCHED AVATAR: ${surveyor?.avatar}");
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile();
    });
  } else {
    Utils.showToast("Session expired. Please login again");
    Get.offAll(() => const LoginPage());
  }
}

    final RxnString selectedState = RxnString();
  final RxnString selectedCity = RxnString();



  void fetchProfile() {
    callWebApiGet(
     
      // null,
       _tickerProvider,
      ApiEndpoints.getProfile,
      //   showLoader: false, 
      // hideLoader: false,
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

 
 

Future<void> updateProfile({
  required String name,
//  required String email,
  File? image,
  String? lat,
  String? long,
}) async {


 
  final state = selectedState.value;
  final city = selectedCity.value;

  if (state == null || state.isEmpty) {
    Utils.showToast("Please select state");
    return;
  }

  if (city == null || city.isEmpty) {
    Utils.showToast("Please select district");
    return;
  }

  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse(ApiEndpoints.updateProfile),
    );

    request.headers['Authorization'] = 'Bearer $authToken';

    // request.fields['id'] = userId;
    request.fields['name'] = name;
    //request.fields['email'] = email;
    request.fields['state'] = state;        
    request.fields['city'] = city;           
    request.fields['current_lat'] = lat??'';  
    request.fields['current_lng'] = long??''; 

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', image.path), 
      );
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
   try {
  var jsonResponse = jsonDecode(responseData);
  print("UPDATE PROFILE RESPONSE: $responseData");

  final result = EditProfileResponseModel.fromJson(jsonResponse);

  if (result.status == "success") { 
    Utils.showToast(result.message ?? "Profile Updated Successfully");
    fetchProfile();
    Get.back();
  } else {
    Utils.showToast(result.message ?? "Update failed");
  }
} catch (e) {
  print("PARSE ERROR: $e"); 
  Utils.showToast("Something went wrong");
}

  } catch (e) {
    Utils.print(e.toString());
  }
}

}



