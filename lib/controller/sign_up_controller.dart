import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/dynamic_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:surveyor_app_planzaa/common/load_manager.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/login_response_model.dart';
import 'package:surveyor_app_planzaa/modal/signup_response_model.dart';
import 'package:surveyor_app_planzaa/pages/otp_verify.dart';


class SignUpController extends GetxController {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirnPasswordController = TextEditingController();
  Rx<SingUpResponseModel> signUpResponseModel = SingUpResponseModel().obs;



  final TickerProvider _tickerProvider;

  SignUpController(this._tickerProvider);


RxBool isPasswordVisible = false.obs;
RxBool isConfirmPasswordVisible = false.obs;

  register() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirnPasswordController.text.trim();
  if (password.length < 8) {
    Utils.showToast("Password must be at least 8 characters long");
    return;
  }

  if (password != confirmPassword) {
    Utils.showToast("Passwords do not match");
    return;
  }  
    if (email.isEmpty || phone.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        Utils.showToast("All fields are required to fill"); 
      
      return;
    }

    Map<String, String> data = {
      'email': email,
       "phone": phone, 
       "name": name,
        "password": password, 
        "confirm_password": confirmPassword  
        };

    callWebApi(
      _tickerProvider,
     ApiEndpoints.register,
      data,
      onResponse: (http.Response response) async {
  var responseJson = jsonDecode(response.body);

  try {
    signUpResponseModel.value =
        SingUpResponseModel.fromJson(responseJson);

    if (response.statusCode == 200 &&
        signUpResponseModel.value.status == "success") {

      Get.to(() => OtpVerify(
        email: email,
        name: name,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        isForgotFlow: false,
      ));

    } else {
     
      Utils.showToast(
        signUpResponseModel.value.message ??
        "Registration failed",
      ); 
    }

  } catch (e) {
    LoaderManager.hideLoader();
    Utils.print(e.toString());
    Utils.showToast("Something went wrong");
  }

  Utils.print("sign up controller %%%%%%%%%%%%%%%%%%%% ");
},
      token: "",
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirnPasswordController.dispose();
    super.onClose();
  }
}
