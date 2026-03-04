import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/common_text_field.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/login_controller.dart';
import 'package:surveyor_app_planzaa/pages/changePassword.dart';
import 'package:surveyor_app_planzaa/pages/sign_up_page.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // final SignInController signInController = Get.put(SignInController());
  late LoginController loginController;
  @override
  void initState() {
    super.initState();
    loginController = Get.put(LoginController(this));
  }

// @override
// void dispose() {
//   loginController.emailController.dispose();
//   loginController.passwordController.dispose();
//   super.dispose();
// }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0, 
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.42,
              child: Image.asset(
                Assets.bgPNG,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                 width: double.infinity,
                // height: screenHeight * 0.46,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(   
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [ 
                      ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: 1,
                          child: Image.asset(
                            // 'assets/logo.png',
                            Assets.appLogoPNG,
                            height: Get.height * 0.06,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 20),
                      SizedBox(height: Get.height * 0.019),
                      Utils.textView(
                        "Let's sign you in",
                        Get.width * 0.06,
                        CustomColors.black,
                        FontWeight.bold,
                      ),
                  
                      SizedBox(height: Get.height * 0.01),
                      Utils.textView(
                        "Welcome back! Enter your details to continue.",
                        Get.width * 0.036,
                        CustomColors.textGrey,
                        FontWeight.normal,
                      ),
                  
                      SizedBox(height: Get.height * 0.03),
                  
                      CommonTextField(  
                        () {}, 
                        svg: Assets.emailSVG,
                        controller: loginController.emailController,
                        inputTypeKeyboard: TextInputType.emailAddress,
                        obscureText: false,
                        keyboardActionType: TextInputAction.done,
                      //  inputTypeKeyboard: TextInputType.emailAddress,
                        lineFormatter:FilteringTextInputFormatter.singleLineFormatter,
                        hintText: "Enter Registered Email",
                        maxLength: 999,
                        obscure: false,
                        onChanged: () {},    
                      ),
                       SizedBox(height: Get.height * 0.03),
                  
                      Obx(
  () => CommonTextField(
    () {},
    svg: Assets.passwordSVG,
    controller: loginController.passwordController,
    keyboardActionType: TextInputAction.done,
    inputTypeKeyboard: TextInputType.visiblePassword,
    lineFormatter:
        FilteringTextInputFormatter.singleLineFormatter,
    hintText: "Password",
    maxLength: 999,
    obscureText: !loginController.isPasswordVisible.value,
    obscure: true,
    onChanged: () {},

    suffixIcon: IconButton(
      icon: Icon(
        loginController.isPasswordVisible.value
            ? Icons.visibility
            : Icons.visibility_off,
        color: CustomColors.outlineGrey,
      ),
      onPressed: () {
       loginController.isPasswordVisible.value =
    !loginController.isPasswordVisible.value; 
      },
    ),
  ),
),
                  
                    // /  SizedBox(height: Get.height * 0.01),

                      Obx(() => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        Checkbox(
          value: loginController.rememberMe.value,
          activeColor: CustomColors.boxColor,
          onChanged: (value) {
            loginController.rememberMe.value = value ?? false;
            loginController.handleRememberMe();
          },
        ),
        GestureDetector(
          onTap: () {
            loginController.rememberMe.value =
                !loginController.rememberMe.value;
            loginController.handleRememberMe();
          },
          child: Utils.textView(
            "Remember me",
            Get.height * 0.018,
            CustomColors.black,
            FontWeight.normal,
          ),
        ),
      ],
    ),

    TextButton(
      onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePassword(phone: loginController.emailController.text,),
            ),
          );
      },
      child: Utils.textView( 
        "Forgot Password?",
        Get.height * 0.018,
        CustomColors.boxColor,
        FontWeight.normal,
      ),
    ),
  ],
)),
                  SizedBox(height: Get.height * 0.03),
                      SizedBox(
                        width: double.infinity,
                        height: Get.height * 0.06,
                        child:  ElevatedButton(
                          onPressed: () {
                            loginController.login();
                          },
                           // onPressed:signInController.sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.boxColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:  Utils.textView(
                                    "Log In",
                  
                                    Get.height * 0.02,
                                    CustomColors.white,
                                    FontWeight.bold,
                                  ),
                          ),
                        ),
                      
                  
                      SizedBox(height: Get.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const Text("Don't have an account?"),
                          Utils.textView(
                            "Don't have an account?",
                            Get.height * 0.018,
                            CustomColors.black,
                            FontWeight.normal,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            child: Utils.textView(
                              "Sign Up",
                              Get.height * 0.018,
                              CustomColors.boxColor,
                              FontWeight.normal,
                            ),
                          ),
                        ], 
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  
  
  
  }
}
