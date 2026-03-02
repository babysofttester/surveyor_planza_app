import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/otp_veriry_controller.dart';

class OtpVerify extends StatefulWidget {
  final String email;
  final String? name;
  final String? phone;
  final String? password;
  final String? confirmPassword;

  const OtpVerify({
    super.key,
    required this.email,
    required this.name,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> with TickerProviderStateMixin {
  late OtpVerifyController otpVerifyController;

  @override
  void initState() {
    super.initState();
    otpVerifyController = Get.put(OtpVerifyController(widget.email, this));
  }

  // 6 controllers for 6 OTP digits
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // 6 focus nodes to control focus between fields
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.49,
            child: Image.asset(
              // 'assets/bgImage.png',
              Assets.bgPNG,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              //height: screenHeight * 0.53,
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
                          Assets.appLogoPNG,
                          // 'assets/logo.png',
                          height: Get.height * 0.06,
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.019),
                    const SizedBox(height: 10),
                    Utils.textView(
                      "OTP Verification",
                      Get.width * 0.06,
                      CustomColors.black,
                      FontWeight.bold,
                    ),
                    // const Text(
                    //   "OTP Verification",
                    //   style:
                    //   TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(height: 6),
                    Text(
                      //'kjk',
                      "Enter the 6-digit code sent to ${otpVerifyController.email}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 2), 
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none, 
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _focusNodes[index].unfocus();
                                }
                              } else {
                                if (index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              }
                            },
                            cursorColor: Color(0xFF1F3C88),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),
                    //resend otp
                    Obx(
                      () => Text(
                        otpVerifyController.canResend.value
                            ? "Didn't receive OTP?"
                            : "You can resend in ${otpVerifyController.secondsRemaining}s",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    Obx(
                      () => Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          //  backgroundColor: Colors.blue,
                            backgroundColor: otpVerifyController.canResend.value
                            ? const Color(0xFF3AAFA9)
                            : Colors.grey, // disabled color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: otpVerifyController.canResend.value
                              ? otpVerifyController.resendOtp
                              : null,
                          child: Text(
                            otpVerifyController.canResend.value
                                ? "Resend OTP"
                                : "Resend in ${otpVerifyController.secondsRemaining}s",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3C88),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          String otp = _otpControllers
                              .map((controller) => controller.text) 
                              .join();

                          otpVerifyController.verifyOtp(
                            otp: otp,
                            name: widget.name ?? "",
                            phone: widget.phone ?? "",
                            password: widget.password ?? "",
                          );
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                    // ElevatedButton(
                    //   onPressed: () {
                    //     String otp = _otpControllers.map((e) => e.text).join();
                    //     authController.verifyOtp(otp);
                    //   },
                    //   child: const Text("Log In"),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
