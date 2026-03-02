
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';

// ignore: must_be_immutable
class CommonTextField extends StatefulWidget {
  String svg;
  TextEditingController controller;
  TextInputAction keyboardActionType;
  TextInputType inputTypeKeyboard;
  TextInputFormatter lineFormatter;
  String hintText;
  int maxLength;
  bool obscureText;
  bool obscure;
  Function? onSubmitted;
  Function? onChanged;
  final Widget? suffixIcon;
  
  CommonTextField(
    this.onSubmitted, {
    required this.svg,
    required this.controller,
    required this.keyboardActionType,
    required this.inputTypeKeyboard,
    required this.lineFormatter,
    required this.hintText,
    required this.maxLength,
    required this.obscureText,
    required this.obscure,
    required this.onChanged,
    this.suffixIcon,
    super.key,
  });

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width < 600
          ? Get.width * 0.13
          : Get.width * 0.085,
      margin: const EdgeInsets.only(
        // left: Get.width * 0.03,
        // right: Get.width * 0.03,
        // top: Get.height * 0.02,
        // bottom: Get.height * 0.02,
      ),
      padding: MediaQuery.of(context).size.width < 600
          ? EdgeInsets.only(left: Get.width * 0.06, right: Get.width * 0.06)
          : EdgeInsets.only(left: Get.width * 0.03, right: Get.width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomColors.textGrey),
        // boxShadow: const [
        //   BoxShadow(
        //     blurRadius: 5,
        //     color: Colors.white,
        //   ),
        //   BoxShadow(
        //     offset: Offset(1, 2),
        //     blurRadius: 5,
        //     spreadRadius: 2,
        //     color: CustomColors.outlineGrey,
        //     inset: true,
        //   ),
        // ],
      ),
     
      child: Row(
  children: [
    SvgPicture.asset(
      widget.svg,
      height: Get.height * 0.025,
      color: CustomColors.outlineGrey,
    ),

    SizedBox(width: Get.width * 0.02),

    Expanded(
      child: TextField(
        cursorColor: CustomColors.black,
        controller: widget.controller,
        textInputAction: widget.keyboardActionType,
        maxLength: widget.maxLength,
        keyboardType: widget.inputTypeKeyboard,
        obscureText: widget.obscureText,
        inputFormatters: [widget.lineFormatter],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle:
              const TextStyle(color: CustomColors.textGrey),
          counterText: '',
        ),
      ),
    ),

    if (widget.suffixIcon != null) widget.suffixIcon!,
  ],
),
      // Row(
      //   children: [
      //     // GestureDetector(
      //     //   onTap: () {
      //     //     setState(() {
      //     //       if (widget.obscure == true) {
      //     //         widget.obscureText = !widget.obscureText;
      //     //       }
      //     //     });
      //     //   },
      //     //   child: SvgPicture.asset(
      //     //     widget.svg,
      //     //     semanticsLabel: 'one',
      //     //     height: Get.height * 0.025,
      //     //     // ignore: deprecated_member_use
      //     //     color: CustomColors.outlineGrey,
      //     //   ),
      //     // ),
      //     SizedBox(width: Get.width * 0.02),
      //     Flexible(
      //       child: TextField(
      //         cursorColor: CustomColors.black,
      //         controller: widget.controller,
      //         textInputAction: widget.keyboardActionType,
      //         maxLength: widget.maxLength,
      //         keyboardType: widget.inputTypeKeyboard,
      //         obscureText: widget.obscureText,
      //         onSubmitted: (value) {
      //           widget.onSubmitted;
      //         },
      //         onChanged: (value) {
      //           widget.onChanged;
      //         },
      //         inputFormatters: [widget.lineFormatter],
      //         decoration: InputDecoration(
      //           border: InputBorder.none,
      //           focusedBorder: InputBorder.none,
      //           enabledBorder: InputBorder.none,
      //           errorBorder: InputBorder.none,
      //           disabledBorder: InputBorder.none,
      //           hintText: widget.hintText,
      //           hintStyle: const TextStyle(color: CustomColors.textGrey),
      //           counterText: '',
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    
    
    );
  }
}
