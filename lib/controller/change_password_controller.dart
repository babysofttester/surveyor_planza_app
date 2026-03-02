import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/core/storage/token_services.dart';
import 'package:surveyor_app_planzaa/modal/forgot_password_response_model.dart';
import 'package:surveyor_app_planzaa/pages/otp_verify.dart';

class ChangePasswordController extends GetxController {

  final TickerProvider tickerProvider;

  ChangePasswordController(this.tickerProvider);

  TextEditingController phoneController = TextEditingController();

  String? authToken;

  Future<void> sendOtp() async {

    if (phoneController.text.isEmpty) {
      Utils.showToast("Error: Please enter Phone Number");
      // Get.snackbar("Error", "Please enter phone number");
      return;
    }

    authToken = await TokenService.getToken(); 

    Map<String, dynamic> body = {
      "phone": phoneController.text.trim(),
    };

    callWebApi(
      tickerProvider,
      ApiEndpoints.forgotPassword,   
      body,
      token: authToken,              
      onResponse: (response) {

        final decoded = jsonDecode(response.body);

        ForgotPasswordResponseModel model =
            ForgotPasswordResponseModel.fromJson(decoded);

        if (model.status == "success") {
        Utils.showToast("Success: ${model.message ?? "OTP Sent"}");
          // Get.snackbar("Success", model.message ?? "OTP Sent"); 

          
          Get.to(() => OtpVerify(email: '', name: '', phone: '', password: '', confirmPassword: '',));

        } else {
           Utils.showToast("Error: ${model.message ?? "Something went wrong"}");
          // Get.snackbar("Error", model.message ?? "Something went wrong");
        }
      },
      onError: (error) {
        Utils.showToast("Error: ${error.toString()}");
        // Get.snackbar("Error", error.toString());
      },
    );
  }
}