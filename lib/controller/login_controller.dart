import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/load_manager.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/login_response_model.dart';
import 'package:surveyor_app_planzaa/pages/home.dart';
import 'package:surveyor_app_planzaa/pages/kyc_screen.dart';
import 'package:surveyor_app_planzaa/pages/otp_verify.dart';


class LoginController extends GetxController {
  final TickerProvider _tickerProvider;

  LoginController(this._tickerProvider);
  
  // ✅ late, initialized in onInit
  late TextEditingController emailController;
  late TextEditingController passwordController;
 // final emailController = TextEditingController();
  // final isLoading = false.obs;
Rx<LoginResponseModel> loginResponseModel = LoginResponseModel().obs;
  String? authToken;
  late SharedPreferences prefs;

  RxBool rememberMe = false.obs;
//final passwordController = TextEditingController();
RxBool isPasswordVisible = false.obs;


  @override
  Future<void> onInit() async {
    super.onInit();
     
    emailController = TextEditingController();
    passwordController = TextEditingController();

    prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool("remember_me") ?? false;

  if (rememberMe.value) {
    emailController.text = prefs.getString("saved_email") ?? "";
  }
  }


  Future<void> handleRememberMe() async {
  if (rememberMe.value) {
    await prefs.setBool("remember_me", true);
    await prefs.setString("saved_email", emailController.text.trim());
  } else {
    await prefs.setBool("remember_me", false);
    await prefs.remove("saved_email");
  }
}


bool _isDisposed = false;




Future<void> login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty) {
    Utils.showToast("Please enter email");
    return;
  }

  if (password.isEmpty) {
    Utils.showToast("Please enter password");
    return;
  }
 if (_isDisposed) return;

  Map<String, String> data = {
    "email": email,
    "password": password,
    "fcm_token": "abn",
  };

  callWebApi(
  //  null,
  _tickerProvider,
  ApiEndpoints.login,
  data,
  onResponse: (http.Response response) async {
    var responseJson = jsonDecode(response.body);
try{
loginResponseModel.value =
        LoginResponseModel.fromJson(responseJson);

    if (response.statusCode == 200 &&
        loginResponseModel.value.status == "success") {

      String token =
          loginResponseModel.value.data?.token ?? "";

     
      await prefs.setString(Constants.AUTH_TOKEN, token);
      await prefs.setInt(Constants.IS_LOGGED_IN, 1); 
      await prefs.setString(Constants.KEY_LOGIN_RESPONSE, jsonEncode(responseJson)); 
    

      await handleRememberMe();

      Utils.showToast(loginResponseModel.value.message ?? "Login Success");

int isVerified = loginResponseModel.value.data?.isVerified ?? 0;
int isRejected = loginResponseModel.value.data?.isRejected ?? 0;
int isPending = loginResponseModel.value.data?.isPending ?? 0;
int isNotCompleted = loginResponseModel.value.data?.isNotCompleted ?? 0;

if (isVerified == 1) {

  
  Get.offAll(() => Home());

} else if (isRejected == 1) {


  Get.offAll(() => const KycScreen());

} else if(isNotCompleted == 1){
  Get.offAll(()=> const KycScreen());
}
else if (isPending == 1) {  

  
  
  Utils.showToast(
    "Your KYC verification is currently under review. "
    "Please wait until our team verifies your documents."
  ); 

} 


 else {
   Get.offAll(() => const KycScreen()); 
 
}
      
      // Get.offAll(() => Home());
    
print("isVerified: $isVerified");
print("isRejected: $isRejected");
print("isPending: $isPending");
print("isNotCompleted: $isNotCompleted");
    } else {
     
      Utils.showToast(
        loginResponseModel.value.message ??
        "Invalid credentials or account inactive",
      );
    }
}catch (e){
          LoaderManager.hideLoader();
          e.printError();
          e.printInfo();
          Utils.print(e.toString());
}
    Utils.print("log in controller %%%%%%%%%%%%%%%%%%%% ");
  },
  token: authToken,
);
}

// @override
// void onClose() {
//   _isDisposed = true;
//   emailController.dispose();
//   passwordController.dispose();
//   super.onClose();
// }
}
