import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/load_manager.dart';
import 'package:surveyor_app_planzaa/common/multipart_api_call.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart' as api;
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/login_response_model.dart';
import 'package:surveyor_app_planzaa/pages/home.dart';
import 'package:surveyor_app_planzaa/pages/kyc_screen.dart';



class OtpVerifyController extends GetxController {
  late String authToken;
  late SharedPreferences prefs;
  final TickerProvider _tickerProvider;

  final secondsRemaining = 30.obs;
  final canResend = false.obs;




  static const String resendOtpUrl = '';

  String email;

  OtpVerifyController(this.email, this._tickerProvider);

   Rx<LoginResponseModel> loginResponseModel = LoginResponseModel().obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    _startTimer();
  }

  // ---------------- TIMER ----------------
  void _startTimer() {
    secondsRemaining.value = 30;
    canResend.value = false;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (secondsRemaining.value == 0) {
        canResend.value = true;
        return false;
      }
      secondsRemaining.value--;
      return true;
    });
  }

  //resend otp
  resendOtp() async {
    Map<String, String> data = {'email': email};

    api.callWebApi(
      _tickerProvider,
      ApiEndpoints.login,
      data,
      onResponse: (http.Response response) async {
        var responseJson = jsonDecode(response.body);
        try {
          loginResponseModel.value = LoginResponseModel.fromJson(
            responseJson,
          );
          if (loginResponseModel.value.status == "success") {
          } else if (loginResponseModel.value.error == null ||
              loginResponseModel.value.error == "") {
            Utils.showToast("${loginResponseModel.value.error}");
          }
        } catch (e) {
          LoaderManager.hideLoader();
          e.printError();
          e.printInfo();
          Utils.print(e.toString());
        }

        Utils.print("sign in controller %%%%%%%%%%%%%%%%%%%% ");
      },
      token: "",
    );
  }
  // ---------------- VERIFY OTP ----------------
Future<void> verifyOtp({
  required String otp,
  required String name,
  required String phone,
  required String password,
}) async {
    String fcmToken = prefs.getString(Constants.fcmToken) ?? "abc";

  if (otp.length != 6) {
    Utils.showToast("Please enter valid 6-digit OTP");
    return;
  }
 
  Map<String, String> data = {
    "email": email.trim(),
    "name": name.trim(),
    "phone": phone.trim(),
    "password": password.trim(),
    "password_confirmation": password.trim(),
    "otp": otp.trim(),
    "fcm_token": fcmToken,
  };

  callMultipartWebApi(
    _tickerProvider, 
    ApiEndpoints.verifyOtp,
    data,
    [],
    onResponse: (response) async {
      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseJson["status"] == "success") {

        final token = responseJson["data"]["token"] ?? "";
        await prefs.setString("auth_token", token);

        Utils.showToast(responseJson["message"] ?? "OTP Verified");

        Get.to(() => KycScreen());

      } else {
        Utils.showToast(
            responseJson["message"] ?? "Verification failed");
      }
    }, 
    
    token: '',
  );
}

}