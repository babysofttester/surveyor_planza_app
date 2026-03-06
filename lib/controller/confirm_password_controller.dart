import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/multipart_api_call.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/login_controller.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';

class ConfirmPasswordController extends GetxController {
  // final TickerProvider tickerProvider;
  final String userId;
  ConfirmPasswordController(this.userId);

  // ConfirmPasswordController(this.tickerProvider, this.userId);

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;

  void changePassword() {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Utils.showToast("Please fill all fields");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Utils.showToast("Passwords do not match");
      return;
    }

    Map<String, String> data = {
      "id": userId,
      "password": passwordController.text.trim(),
      "password_confirmation": confirmPasswordController.text.trim(),
    };

    callMultipartWebApi(
      null,
      // tickerProvider,
      ApiEndpoints.changePassword,
      data,
      [],
      onResponse: (response) {
        final responseJson = jsonDecode(response.body);

        if (response.statusCode == 200 && responseJson["status"] == "success") {
          Utils.showToast(responseJson["message"] ?? "Password Updated");

        
Get.offAll(() => const LoginPage());
        } else {
          Utils.showToast(
            responseJson["message"] ?? "Failed to update password",
          );
        }
      },
      token: '',
    );
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
