import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/common_text_field.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/change_password_controller.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
    with TickerProviderStateMixin {

  late ChangePasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChangePasswordController(this));
  }

  @override
  void dispose() {
    Get.delete<ChangePasswordController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      
                      Image.asset(
                        Assets.appLogoPNG,
                        height: Get.height * 0.06,
                      ),

                      SizedBox(height: Get.height * 0.02),

                      
                      Utils.textView(
                        "Forgot Password?",
                        Get.width * 0.06,
                        CustomColors.black,
                        FontWeight.bold,
                      ),

                      SizedBox(height: Get.height * 0.01),

                    
                      Utils.textView(
                        "Enter your registered phone number to receive OTP.",
                        Get.width * 0.036,
                        CustomColors.textGrey,
                        FontWeight.normal,
                      ),

                      SizedBox(height: Get.height * 0.04),

                    
                      CommonTextField(
                        () {},
                        svg: Assets.callSVG, 
                        controller: controller.phoneController,
                        inputTypeKeyboard: TextInputType.number,
                        keyboardActionType: TextInputAction.done,
                        lineFormatter:
                            FilteringTextInputFormatter.digitsOnly,
                        hintText: "Enter Phone Number",
                        maxLength: 10,
                        obscure: false,
                        obscureText: false,
                        onChanged: () {},
                      ),

                      SizedBox(height: Get.height * 0.04),

                    
                      SizedBox(
                        width: double.infinity,
                        height: Get.height * 0.06,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.sendOtp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.boxColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Utils.textView(
                            "Send OTP",
                            Get.height * 0.02,
                            CustomColors.white,
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.02),

                    
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Utils.textView(
                          "Back to Login",
                          Get.height * 0.018,
                          CustomColors.boxColor,
                          FontWeight.normal,
                        ),
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