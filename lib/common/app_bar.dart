import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
// import 'package:miracle_manager/common/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'dart:async';
import 'constants.dart';
import 'custom_colors.dart';
import 'package:http/http.dart' as http;

class AppBarController extends GetxController {
  RxBool isLocationEnabled = false.obs;
  StreamSubscription<ServiceStatus>? _serviceStatusStream;

  // final GlobalKey _fourteen = GlobalKey();
  // final GlobalKey _fifteen = GlobalKey();
  late SharedPreferences prefs;
  @override
  void onInit() {
    super.onInit();
    checkLocationStatus();
    // startLocationStatusMonitor();
    load();
    // listenToLocationServiceChanges();
  }

  load() async {
    prefs = await SharedPreferences.getInstance();
  }

 


/*   Future<void> checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationEnabled.value = serviceEnabled;
  } */

  // Check if location service is enabled
  Future<void> checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationEnabled.value = serviceEnabled;

    // if (!serviceEnabled) {
    //   // Navigate to the "Enable Location" page
    //   Get.to(() => const EnableLocationPage())?.then((_) {
    //     // Check again when returning from the page
    //     checkLocationStatus();
    //   });
    // }
  }

 

  @override
  void onClose() {
    _serviceStatusStream
        ?.cancel(); // Stop listening when the controller is closed
    super.onClose();
  }




}




PreferredSizeWidget getAppBarCustom(
  Color color,
  GlobalKey<ScaffoldState> scaffoldKey,
  String title,
  String? subHeading,
) {
  final AppBarController appBarController = Get.put(AppBarController());


  RxString uni = "".obs;

  RxBool toUSEObx = true.obs;
  // appBarController.checkAndShowWalkthrough();
  return PreferredSize(
    preferredSize: Size.fromHeight(Get.width * 0.18),
    child: Stack(clipBehavior: Clip.none, children: [
      AppBar(
        backgroundColor: CustomColors.appBarColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: Get.width * 0.18,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo-icon-old.png",
              width: Get.width * 0.1,
              height: Get.width * 0.1,
            ),
            Column(
              children: [
                Obx(
                  () => toUSEObx.value == true
                      ? Text(
                          title,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: Get.width < 600
                                  ? Get.width * 0.05
                                  : Get.width * 0.035),
                        )
                      : const SizedBox(),
                ),
                subHeading != null
                    ? Text(
                        subHeading,
                        style: TextStyle(
                            color: CustomColors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: Get.width < 600
                                ? Get.width * 0.03
                                : Get.width * 0.025),
                      )
                    : const SizedBox(),
                Utils.textView("Planza",
                    Get.width * 0.02, CustomColors.white, FontWeight.normal)
              ],
            )
          ],
        ),
        // leadingWidth: Get.width > 600 ? Get.width * 0.4 : Get.width * 0.25,
        actions: [
          Obx(
            () => Padding(
              padding: EdgeInsets.all(Get.width > 600 ? Get.width * 0.01 : 0),
              child: Icon(
                appBarController.isLocationEnabled.value
                    ? Icons.location_on
                    : Icons.location_off,
                color: Colors.white,
                size: Get.width > 600 ? Get.width * 0.06 : Get.width * 0.08,
              ),
            ),
          ),
          Obx(
            () => PopupMenuButton(
                icon: uni.value == "👤"
                    ? SvgPicture.asset(
                        Assets.userSVG,
                        color: Colors.orange,
                      )
                    : Text(
                        uni.value,
                        style: TextStyle(fontSize: Get.width * 0.08),
                      ),
               
          
                itemBuilder: (context) {
          
                
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Utils.textView(
                         "Logout",
                          Get.width < 600
                              ? Get.width * 0.04
                              : Get.width * 0.03,
                          CustomColors.black,
                          FontWeight.bold,
                        ),
                      ),
                    ];
                  
          
                  // Non-external → show both
                 
                },
       ),
         )   ],
        leading: Row(
          children: [
            InkWell(
              child: Container(
                // color: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      Get.width > 600 ? Get.width * 0.015 : Get.width * 0.04,
                  vertical:
                      Get.width > 600 ? Get.width * 0.015 : Get.width * 0.04,
                ),
                child: SvgPicture.asset(
                  'assets/svg/menu.svg',
                  height: Get.height * 0.03,
                  width: Get.height * 0.03,
                  color: CustomColors.white,
                ),
              ),
              onTap: () {
                // FocusManager.instance.primaryFocus?.unfocus();
                if (FocusManager.instance.primaryFocus != null &&
                    FocusManager.instance.primaryFocus!.hasFocus) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }

                scaffoldKey.currentState!.openDrawer();
              },
            ),
            const SizedBox(
                // width: Get.width * 0.04,
                ),
          ],
        ),
      ),
      
    ]),
  );
}
