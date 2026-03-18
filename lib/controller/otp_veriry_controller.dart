import 'dart:convert';

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
import 'package:surveyor_app_planzaa/pages/confirm_password.dart';
import 'package:surveyor_app_planzaa/pages/kyc_screen.dart';

class OtpVerifyController extends GetxController {
  late String authToken;
  late SharedPreferences prefs;
  final TickerProvider _tickerProvider;

    VoidCallback? onResendSuccess;

  final secondsRemaining = 30.obs;
  final canResend = false.obs;

  static const String resendOtpUrl = '';

  String email;
  final bool isForgotFlow;

    final String name;
  final String phone;
  final String password;


  OtpVerifyController(
    this.email, 
    this._tickerProvider, 
    this.isForgotFlow,{
    this.name = "",
    this.phone= "",
    this.password="",
    }
    
    );

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

  if(isForgotFlow){
    print("Debug => phone:$phone");

    Map<String, String> data = {
      'phone': phone,
    };
     callMultipartWebApi(
      _tickerProvider, 
      ApiEndpoints.forgotPassword, 
      data,
      [],
      onResponse: (response) async {
        var responseJson = jsonDecode(response.body);
        try {
          if (responseJson["status"] == "success") {
            Utils.showToast("OTP resent successfully");
            onResendSuccess?.call();
            _startTimer();
          } else {
            Utils.showToast("Incorrect OTP");
          }
        } catch (e) {
          LoaderManager.hideLoader();
          Utils.print(e.toString());
        }
      },
      token: "",
    );

  }else {
 print("DEBUG => email:$email | name:$name | phone:$phone | password:$password");

  Map<String, String> data = {
    'email': email,
    'name': name,
    'phone': phone,
    'password': password, 
    'password_confirmation': password,
  };

  callMultipartWebApi(
    _tickerProvider,
    ApiEndpoints.register,
    data,
    [],
    onResponse: (response) async {
      var responseJson = jsonDecode(response.body);
      try {
        if (responseJson["status"] == "success") {
          Utils.showToast("OTP resent successfully");
          onResendSuccess?.call(); 
          _startTimer();
        } else {
          Utils.showToast(responseJson["message"] ?? "Failed to resend OTP");
        }
      } catch (e) {
        LoaderManager.hideLoader();
        Utils.print(e.toString());
      }
    },
    token: "",
  );

  }
 

}

  // ---------------- VERIFY OTP ----------------
  Future<void> verifyOtp({
    required String otp,
    required String name,
    required String phone,
    required String password,
  }) async {
    if (otp.length != 6) {
      Utils.showToast("Please enter valid 6-digit OTP");
      return;
    }

    Map<String, String> data;

    if (isForgotFlow) {
      data = {"phone": phone.trim(), "otp": otp.trim()};
    } else {
      String fcmToken = prefs.getString(Constants.fcmToken) ?? "abc";

      data = {
        "email": email.trim(),
        "name": name.trim(),
        "phone": phone.trim(),
        "password": password.trim(),
        "password_confirmation": password.trim(),
        "otp": otp.trim(),
        "fcm_token": fcmToken,
      };
    }

    callMultipartWebApi(
      _tickerProvider,
      isForgotFlow ? ApiEndpoints.forgotVerifyOtp : ApiEndpoints.verifyOtp,
      data,
      [],
      onResponse: (response) async {
        final responseJson = jsonDecode(response.body);
        print(responseJson);

        if (response.statusCode == 200 && responseJson["status"] == "success") {
          if (isForgotFlow) {
            
            Get.to(
              () => ConfirmPassword(
                userId: responseJson["data"]["user"]["id"].toString(),
              ),
            );
          } else {
            final token = responseJson["data"]["token"] ?? "";
            await prefs.setString("auth_token", token);
            Get.to(() => KycScreen());
          }
        } else {
          Utils.showToast("Incorrect OTP");
        }
      },
      token: '',
    );
  }
}
