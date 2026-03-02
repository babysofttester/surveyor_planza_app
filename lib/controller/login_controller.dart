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

  final emailController = TextEditingController();
  // final isLoading = false.obs;
Rx<LoginResponseModel> loginResponseModel = LoginResponseModel().obs;
  String? authToken;
  late SharedPreferences prefs;

  RxBool rememberMe = false.obs;
final passwordController = TextEditingController();
RxBool isPasswordVisible = false.obs;


  @override
  Future<void> onInit() async {
    super.onInit();
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

Future<void> login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty) {
    Utils.showToast("Error: Please enter email");
    return;
  }

  if (password.isEmpty) {
    Utils.showToast("Error: Please enter password");
    return;
  }

  Map<String, String> data = {
    "email": email,
    "password": password,
    "fcm_token": "abn",
  };

  callWebApi(
  _tickerProvider,
  ApiEndpoints.login,
  data,
  onResponse: (http.Response response) async {
    var responseJson = jsonDecode(response.body);

    loginResponseModel.value =
        LoginResponseModel.fromJson(responseJson);

    if (response.statusCode == 200 &&
        loginResponseModel.value.status == "success") {

      String token =
          loginResponseModel.value.data?.token ?? "";

      // await prefs.setString("auth_token", token);
      await prefs.setString(Constants.AUTH_TOKEN, token);
      

      await handleRememberMe();

      Utils.showToast(loginResponseModel.value.message ?? "Login Success");


      // Get.to(()=>KycScreen());
      Get.offAll(() => Home());
     //Get.offAll(() => KycScreen());

    } else {
     
      Utils.showToast(
        loginResponseModel.value.message ??
        "Invalid credentials or account inactive",
      );
    }
  },
  token: authToken,
);
}


@override
void onClose() {
  emailController.dispose();
  passwordController.dispose();
  super.onClose();
}
}
