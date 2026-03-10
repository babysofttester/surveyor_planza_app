import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/common_text_field.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/confirm_password_controller.dart';

class ConfirmPassword extends StatefulWidget {
  final String userId;

  const ConfirmPassword({super.key, required this.userId});

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}

class _ConfirmPasswordState extends State<ConfirmPassword>
    {
  late ConfirmPasswordController controller;

@override
void initState() {
  super.initState();
    controller = Get.put(ConfirmPasswordController(widget.userId));
}
 
 
  @override
  void dispose() {
    Get.delete<ConfirmPasswordController>();
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
              child: Image.asset(Assets.bgPNG, fit: BoxFit.cover),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(Assets.appLogoPNG, height: Get.height * 0.06),

                      SizedBox(height: Get.height * 0.02),

                      Utils.textView(
                        "Create New Password",
                        Get.width * 0.06,
                        CustomColors.black,
                        FontWeight.bold,
                      ),

                      SizedBox(height: Get.height * 0.04),

                      Obx(
                        () => CommonTextField(
                          () {},
                          svg: Assets.passwordSVG,
                          controller: controller.passwordController,
                          keyboardActionType: TextInputAction.done,
                          inputTypeKeyboard: TextInputType.visiblePassword,
                          lineFormatter:
                              FilteringTextInputFormatter.singleLineFormatter,
                          hintText: "New Password",
                          obscure: true,
                          obscureText: !controller.isPasswordVisible.value,
                          maxLength: 50,
                          onChanged: () {},
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              controller.isPasswordVisible.value =
                                  !controller.isPasswordVisible.value;
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.03),

                      Obx(
                        () => CommonTextField(
                          () {},
                          svg: Assets.passwordSVG,
                          controller: controller.confirmPasswordController,
                          keyboardActionType: TextInputAction.done,
                          inputTypeKeyboard: TextInputType.visiblePassword,
                          lineFormatter:
                              FilteringTextInputFormatter.singleLineFormatter,
                          hintText: "Confirm Password",
                          obscure: true,
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          maxLength: 50,
                          onChanged: () {},
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              controller.isConfirmPasswordVisible.value =
                                  !controller.isConfirmPasswordVisible.value;
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.04),

                      SizedBox(
                        width: double.infinity,
                        height: Get.height * 0.06,
                        child: ElevatedButton(
                          onPressed: controller.changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.boxColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Utils.textView(
                            "Update Password",
                            Get.height * 0.02,
                            CustomColors.white,
                            FontWeight.bold,
                          ),
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
