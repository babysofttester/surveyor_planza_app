import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';

import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/modal/login_response_model.dart';
import 'package:surveyor_app_planzaa/pages/home.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';

enum AppStatus { ready, waiting }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SharedPreferences prefs;
  int? isLogin;
  String? loginResponseKey;

  // @override
  // void initState() {
  //   super.initState();

  //   Future.delayed(const Duration(seconds: 3), () {}).then((value) {
  //     getLoginStatus();
  //   });
  // }
@override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 3), getLoginStatus);
}

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }

  getLoginStatus() async {
    prefs = await SharedPreferences.getInstance();

    isLogin = prefs.getInt(Constants.IS_LOGGED_IN);
    Utils.print("$isLogin");

    loginResponseKey = prefs.getString(Constants.KEY_LOGIN_RESPONSE);
    String? storedData = prefs.getString(Constants.KEY_LOGIN_RESPONSE);
    
//     if (isLogin == 1) {
//   if (storedData != null && storedData.isNotEmpty) {
//     try {
//       storedData = storedData.trim();
//       var decodedData = json.decode(storedData);

//       Map<String, dynamic> jsonDataMap = json.decode(storedData);

    
//       if (jsonDataMap['data'] != null &&
//           jsonDataMap['data']['auth_token'] != null) {

//         String authToken = jsonDataMap['data']['auth_token'];
//         await prefs.setString(Constants.AUTH_TOKEN, authToken);

//         LoginResponseModel userModel =
//             LoginResponseModel.fromJson(decodedData);

//         Constants.loginResponseModel = userModel;

//         Utils.print("authtoken: $authToken");

//         Get.offAll(() => const Home());
//       } else {
//         print("Auth token not found");
//         Get.offAll(() => const SignInPage());
//       }

//     } catch (e) {
//       print("ERROR IN SPLASH: $e"); 
//       Get.offAll(() => const SignInPage());
//     }
//   } else {
//     Get.offAll(() => const SignInPage());
//   }
// }

    
    
    if (isLogin == 1) {
      // Ignore: unnecessary_null_comparison
      if (storedData != null && storedData.isNotEmpty) {
        log("${storedData} stored data ");
        try {
          // Decode stored data
          storedData = storedData.trim();
          var decodedData = json.decode(storedData);

          Map<String, dynamic> jsonDataMap = json.decode(storedData);
          String authToken = jsonDataMap['data']['token'];
          prefs.setString(Constants.AUTH_TOKEN, authToken);
          LoginResponseModel userModel = LoginResponseModel.fromJson(
            decodedData,
          );
          Constants.loginResponseModel = userModel;
          Utils.print("authtoken: $authToken");
          // ignore: empty_catches

           Get.offAll(() => const Home());
        } catch (e) {
          log("$e error in catch");
        }
      } else {
        if (kDebugMode) {
          log('No stored data found.');
        }
      }
    } else if (isLogin == 0 || isLogin == null) {
      Get.offAll(
        () => const LoginPage(),
        duration: const Duration(seconds: 1),
        transition: Transition.fade,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.width * 0.3,
              height: Get.width * 0.3,
              child: Image.asset(
                Assets.appLogoPNG,
                height: Get.width,
                width: Get.width,
              ),
            ),
            // Utils.textView("Planza", Get.width * 0.08,
            //     CustomColors.appBarColor, FontWeight.bold),
          ],
        ),
      ),
    
    );
  }
}
