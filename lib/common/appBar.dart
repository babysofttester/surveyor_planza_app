
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) { 
    return AppBar(
      backgroundColor: CustomColors.boxColor,
      elevation: 0,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(
        color: CustomColors.white,
      ),
      title: Utils.textView(
        title,
        MediaQuery.of(context).size.width < 600
            ? Get.width * 0.05
            : Get.width * 0.03,
        CustomColors.white,
        FontWeight.bold,
      ),
      actions: actions,
      
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
