
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/common_text_field.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/sign_up_controller.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  late SignUpController signUpController;

  @override
  void initState() {
    super.initState();
    signUpController = Get.put(SignUpController(this));
  }
  
  @override       
  void dispose() {
    Get.delete<SignUpController>();
    super.dispose(); 
  }

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
              bottom: MediaQuery.of(context).size.height * 0.55,
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
                // height: screenHeight * 0.6,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: CustomColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                       mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 10),
                      ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: 1,
                          child: Image.asset(
                            Assets.appLogoPNG,
                            height: Get.height * 0.06,
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.019),

                      // const SizedBox(height: 20),
                      Utils.textView(
                        "Let's create your account",
                        Get.width * 0.058,
                        CustomColors.black,
                        FontWeight.bold,
                      ),
                      SizedBox(height: Get.height * 0.01),

                      Utils.textView(
                        "Sign up to get started with survey, design, and engineering solutions.",
                        Get.width * 0.036,
                        CustomColors.hintColor,
                        FontWeight.normal,
                      ),

                        SizedBox(height: Get.height * 0.05),

                   
                      CommonTextField(
                        () {},
                        svg: Assets.personPNG, 
                        controller: signUpController.nameController,
                        keyboardActionType: TextInputAction.done,
                        inputTypeKeyboard: TextInputType.text,
                        lineFormatter:
                            FilteringTextInputFormatter.singleLineFormatter,
                        hintText: "Enter your Full Name",
                        maxLength: 999,
                        obscureText: false,
                        obscure: false,
                        onChanged: () {},
                      ),
                      SizedBox(height: Get.height * 0.03),

                   
                      CommonTextField(
                        () {},
                        svg: Assets.emailSVG,
                        controller: signUpController.emailController,
                        keyboardActionType: TextInputAction.done,
                        inputTypeKeyboard: TextInputType.emailAddress,
                        lineFormatter:
                            FilteringTextInputFormatter.singleLineFormatter,
                        hintText: "Enter your Email",
                        maxLength: 999,
                        obscureText: false,
                        obscure: false,
                        onChanged: () {},
                      ),
                      SizedBox(height: Get.height * 0.03),

                    Obx(
  () => CommonTextField(
    () {},
    svg: Assets.passwordSVG,
    controller: signUpController.passwordController,
    keyboardActionType: TextInputAction.done,
    inputTypeKeyboard: TextInputType.visiblePassword,
    lineFormatter:
        FilteringTextInputFormatter.singleLineFormatter,
    hintText: "Password",
    maxLength: 999,
    obscureText: !signUpController.isPasswordVisible.value,
    obscure: true,
    onChanged: () {},

    suffixIcon: IconButton(
      icon: Icon(
        signUpController.isPasswordVisible.value
            ? Icons.visibility
            : Icons.visibility_off,
        color: CustomColors.outlineGrey,
      ),
      onPressed: () {
       signUpController.isPasswordVisible.value =
    !signUpController.isPasswordVisible.value; 
      },
    ),
  ),
),

SizedBox(height: Get.height * 0.03),

 Obx(
  () => CommonTextField(
    () {},
    svg: Assets.passwordSVG,
    controller: signUpController.confirnPasswordController,
    keyboardActionType: TextInputAction.done,
    inputTypeKeyboard: TextInputType.visiblePassword,
    lineFormatter:
        FilteringTextInputFormatter.singleLineFormatter,
    hintText: "Confirm Password",
    maxLength: 999,
    obscureText: !signUpController.isPasswordVisible.value,
    obscure: true,
    onChanged: () {},

    suffixIcon: IconButton(
      icon: Icon(
        signUpController.isPasswordVisible.value
            ? Icons.visibility
            : Icons.visibility_off,
        color: CustomColors.outlineGrey,
      ),
      onPressed: () {
       signUpController.isPasswordVisible.value =
    !signUpController.isPasswordVisible.value; 
      },
    ),
  ),
),

SizedBox(height: Get.height * 0.03),
                      CommonTextField(
                        () {},
                        svg: Assets.callSVG, 
                        controller: signUpController.phoneController,
                        keyboardActionType: TextInputAction.done,
                        inputTypeKeyboard: TextInputType.phone,
                        lineFormatter:
                            FilteringTextInputFormatter.singleLineFormatter,
                        hintText: "Enter your Mobile Number",
                        maxLength: 10,
                        obscureText: false,
                        obscure: false,
                        onChanged: () {},
                      ),

                      

                      SizedBox(height: Get.height * 0.03),
                      

                      SizedBox(
                        width: double.infinity,
                        height: Get.height * 0.06,
                        child: ElevatedButton(
                          // onPressed :() {
                            
                          // },
                         onPressed: signUpController.register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F3C88),
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

                      SizedBox(height: Get.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Utils.textView(
                            "Already have an account?",
                            Get.height * 0.018,
                            CustomColors.black,
                            FontWeight.normal,
                          ),
                          
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: Utils.textView(
                              "Log In",
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
