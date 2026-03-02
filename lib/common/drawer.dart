/* import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:miracle_manager/common/api_urls.dart';
import 'package:miracle_manager/common/assets.dart';
import 'package:miracle_manager/common/constants.dart';
import 'package:miracle_manager/common/translation_singleton.dart';
import 'package:miracle_manager/common/utils.dart';
import 'package:miracle_manager/common/web_service.dart';
import 'package:miracle_manager/model/check_in_response_model.dart';
import 'package:miracle_manager/pages/arrival.dart';
import 'package:miracle_manager/pages/check_out_page.dart';
import 'package:miracle_manager/pages/cleaning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:miracle_manager/pages/departure.dart';
import 'package:miracle_manager/pages/garden_page.dart';
import 'package:miracle_manager/pages/inspection.dart';
// import 'package:miracle_manager/pages/inspection.dart';
import 'package:miracle_manager/pages/meter_location.dart';
import 'package:miracle_manager/pages/pool_page.dart';
import 'package:miracle_manager/pages/start_check_in.dart';
import 'package:miracle_manager/pages/start_end_day.dart';
import 'package:miracle_manager/pages/tasks_page.dart';
import 'package:miracle_manager/pages/whatsapp_manager_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_colors.dart';
import 'package:http/http.dart' as http;

class DrawerData {
  static Rx<CheckInResponseModel> checkInResponseModel =
      CheckInResponseModel().obs;
  static RxBool isLoading = true.obs;

  // Method to fetch data for the drawer
  static Future<void> checkIfClockedIn(Activities activity) async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authToken = prefs.getString(Constants.AUTH_TOKEN);

    Map<String, String> data = {
      "date": DateTime.now().toString(),
    };

    callWebApiWTDrawer(ApiUrls.checkInPage, data,
        onResponse: (http.Response response) async {
      var responseJson = jsonDecode(response.body);

      try {
        checkInResponseModel.value =
            CheckInResponseModel.fromJson(responseJson);

        checkInResponseModel.value.message == null ||
                checkInResponseModel.value.message == ""
            ? const SizedBox()
            : Utils.showToast("${checkInResponseModel.value.message}");
      } catch (e) {
        e.printError();
        e.printInfo();
        log(e.toString());
      }

      // Once the API call is finished, update the loading state
      isLoading.value = false;
    }, token: authToken);
  }

  // Static method to create the drawer widget
  static Widget drawer(Activities activity) {
    RxBool toUseObx = true.obs;
    final isClockIn = Constants.loginResponseModel!.data?.isClockIn == "yes";
    print("isClockIn value $isClockIn");
    // Call the API before the drawer is shown
    checkIfClockedIn(activity);
    log("emp:::  ${Constants.loginResponseModel!.data!.employment} ");

    // log("  user roles::      ${Constants.loginResponseModel!.data!.userRoles!}");

    return SafeArea(
      child: SizedBox(
        width: Get.width < 600 ? 300 : 500,
        child: Drawer(
          child: Container(
            decoration: const BoxDecoration(color: CustomColors.white),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const SizedBox(
                    // height: Get.width * 0.1,
                    ),
                // Use Obx to reactively update UI when the API data is fetched
                Obx(() {
                  if (!toUseObx.value) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show a loading spinner while data is being fetched
                  }
                  return SizedBox(
                    height: Get.width * 0.6,
                    child: DrawerHeader(
                      decoration:
                          const BoxDecoration(color: CustomColors.appBarColor),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          if (activity != Activities.home) {
                            Get.offAll(
                                () => StartEndDay(
                                      name: Constants.appbarHeading.value,
                                    ),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: Get.width * 0.25,
                                  height: Get.width > 600
                                      ? Get.width * 0.25
                                      : Get.width * 0.25,
                                  child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: Constants.userImage,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            height: Get.width * 0.3,
                                            width: Get.width * 0.3,
                                            decoration: BoxDecoration(
                                              // color: Colors.red,
                                              // border: Border.all(),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(100),
                                              ),

                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: SizedBox(
                                              width: 20.0,
                                              height: 20.0,
                                              child: CircularProgressIndicator(
                                                color: CustomColors.blue,
                                              ),
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: CustomColors.white,
                                              // border: Border.all(),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius
                                                  .all(Radius.circular(
                                                      100)), // Ensure clipping
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Image.asset(
                                                  'assets/images/vm.png',
                                                  height: Get.width * 0.3,
                                                  width: Get.width *
                                                      0.3, // Ensure width is defined to match height
                                                  fit: BoxFit
                                                      .contain, // Ensures the image fills the container properly
                                                ),
                                              ),
                                            ),
                                          )
                                      /* Container(
                                      decoration:  BoxDecoration(
                                        border: Border.all(),
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(100))),
                                      child: Image.asset(
                                        'assets/images/logo-icon.png',
                                        height: Get.width * 0.3,
                                      ),
                                    ), */
                                      ),
                                ),
                                SizedBox(
                                  width: Get.width * 0.01,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Constants.userName,
                                      style: TextStyle(
                                          color: CustomColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width < 600
                                              ? Get.width * 0.04
                                              : Get.width * 0.03),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isClockIn &&
                                Constants
                                        .loginResponseModel!.data!.employment ==
                                    "Internal")
                              Utils.textView(
                                Constants.clockInDateTime,
                                Get.width < 600
                                    ? Get.width * 0.03
                                    : Get.width * 0.02,
                                CustomColors.white,
                                FontWeight.normal,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                Obx(() {
                  return checkInResponseModel.value.data?.isUserDayOff ==
                              true ||
                          Constants.dayOff.value == true ||
                          !isClockIn ||
                          Constants.loginResponseModel!.data!.employment ==
                              "External"
                      ? const SizedBox()
                      : _createTile(
                          isSpace: false,
                          isSVG: true,
                          img: Assets.clock_in_out,
                          title:
                              checkInResponseModel.value.data?.isUserClockIn ==
                                              true &&
                                          checkInResponseModel
                                                  .value.data?.isUserClockOut ==
                                              false ||
                                      Constants.clockOutText.value == true
                                  ? TranslationService()
                                      .getTranslation('clock_out_text')
                                  : checkInResponseModel
                                                  .value.data?.isUserClockIn ==
                                              true &&
                                          checkInResponseModel
                                                  .value.data?.isUserClockOut ==
                                              true
                                      ? TranslationService()
                                          .getTranslation('clock_in_text')
                                      : TranslationService()
                                          .getTranslation('clock_in_text'),
                          onTap: () {
                            log("activity: +++ $activity");
                            Get.back();
                            if (activity == Activities.home) {
                              Get.to(
                                  () => StartEndDay(
                                        name: Constants.appbarHeading.value,
                                      ),
                                  transition: Transition.fade,
                                  duration: const Duration(seconds: 1));
                            } else {
                              Get.off(
                                  () => StartEndDay(
                                        name: Constants.appbarHeading.value,
                                      ),
                                  transition: Transition.fade,
                                  duration: const Duration(seconds: 1));
                            }
                          },
                        );
                }),

                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge"))
                    ? _createTile(
                        isSpace: false,
                        isSVG: true,
                        img: Assets.checkInSVG,
                        title: TranslationService()
                            .getTranslation('check_in_text'),

                        // 'Meter Location',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const StartCheckIn(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const StartCheckIn(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),
                // conditions who will be able to see this section

                Constants.loginResponseModel!.data!.employment == "Internal"
                    ? _createTile(
                        isSpace: false,
                        isSVG: true,
                        img: Assets.tasks,
                        title:
                            TranslationService().getTranslation('tasks_text'),
                        onTap: () {
                          log("activity: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const TasksPage(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const TasksPage(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        },
                      )
                    : const SizedBox(),

                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge"))
                    //     ||
                    // Constants.loginResponseModel!.data!.userRoles!
                    //     .contains("Planner")
                    ? _createTile(
                        isSpace: false,
                        isSVG: true,
                        img: Assets.checkOutSVG,
                        title: TranslationService()
                            .getTranslation('check_out_text'),

                        // 'Meter Location',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const StartCheckOut(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const StartCheckOut(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),

                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Planner"))
                    ? _createTile(
                        isSpace: false,
                        isSVG: true,
                        img: Assets.depositSVG,
                        title:
                            TranslationService().getTranslation('deposit_text'),
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            // Get.to(() => const CheckIn(),
                            //     transition: Transition.fade,
                            //     duration: const Duration(seconds: 1));
                          } else {
                            // Get.off(() => const CheckIn(),
                            //     transition: Transition.fade,
                            //     duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),
                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Planner"))
                    ? _createTile(
                        isSpace: false,
                        isSVG: true,
                        img: Assets.electricitySVG,
                        title: TranslationService()
                            .getTranslation('electricity_text'),
                        // 'Operator',
                        onTap: (() {}),
                      )
                    : const SizedBox(),
                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Planner"))
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        img: Assets.checkInSVG,
                        title:
                            TranslationService().getTranslation('arrival_text'),
                        //  'Arrival',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const ArrivalScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const ArrivalScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),
                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Planner"))
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        img: Assets.checkOutSVG,
                        title: TranslationService()
                            .getTranslation('departure_text'),
                        // 'Departure',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const DepartureScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const DepartureScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),
                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Planner"))
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        img: Assets.locationSVG,
                        title: TranslationService()
                            .getTranslation('meter_location_text'),

                        // 'Meter Location',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const MeterLocationScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const MeterLocationScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),

                Constants.loginResponseModel!.data!.userType == "Superadmin" ||
                        Constants.loginResponseModel!.data!.userType ==
                            "Admin" ||
                        Constants.loginResponseModel!.data!.userType ==
                            "Business Unit Manager" ||
                        Constants.loginResponseModel!.data!.userRoles!
                            .contains("Concierge")
                    ? _createTile(
                        isSpace: false,
                        isSVG: true,
                        img: Assets.whatsappManagerSVG,
                        title: TranslationService()
                            .getTranslation('whatsapp_manager_text'),
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(
                                () => WhatsappManagerPage(
                                      guestName: "",
                                      countryCode: "",
                                      bookingId: "",
                                      accessCode: "",
                                      guestPhoneNo: "",
                                      contactName: "",
                                      templateList: const [],
                                    ),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(
                                () => WhatsappManagerPage(
                                      guestName: "",
                                      countryCode: "",
                                      guestPhoneNo: "",
                                      accessCode: "",
                                      contactName: "",
                                      bookingId: "",
                                      templateList: const [],
                                    ),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),

                // Example of other tiles that could be added:
                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userPrivileges!
                                .contains("Operator-cleaning"))
                    ? Obx(
                        () => toUseObx.value == true
                            ? _createTile(
                                isSpace: false,
                                isSVG: true,
                                img: Assets.operatorSVG,
                                title: TranslationService()
                                    .getTranslation('operator_text'),
                                onTap: () {},
                              )
                            : const SizedBox(),
                      )
                    : const SizedBox(),
                /*     Constants.loginResponseModel!.data!.userType == "Superadmin" ||
                        Constants.loginResponseModel!.data!.userType == "Admin" ||
                        Constants.loginResponseModel!.data!.userType ==
                            "Business Unit Manager" ||
                        Constants.loginResponseModel!.data!.userPrivileges!
                            .contains("Operator-cleaning")
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        img: Assets.checkInSVG,
                        title:
                            TranslationService().getTranslation('inspection_text'),
                        //  'Arrival',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const InspectionScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const InspectionScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(), */
                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userPrivileges!
                                .contains("Operator-cleaning"))
                    ? Obx(
                        () => toUseObx.value == true
                            ? _createTile(
                                isSpace: true,
                                isSVG: true,
                                img: Assets.cleaningSVG,
                                title: TranslationService()
                                    .getTranslation('cleaning_text'),
                                // 'Cleaning',
                                onTap: (() {
                                  // checkIfClockedIn(activity);
                                  Get.back();
                                  if (activity == Activities.cleaning) {
                                    Get.to(() => const CleaningScreen(),
                                        transition: Transition.fade,
                                        duration: const Duration(seconds: 1));
                                  } else {
                                    Get.off(() => const CleaningScreen(),
                                        transition: Transition.fade,
                                        duration: const Duration(seconds: 1));
                                  }
                                }),
                              )
                            : szbx(),
                      )
                    : const SizedBox(),

                (Constants.loginResponseModel!.data!.employment == "Internal" &&
                            (Constants.loginResponseModel!.data!.userType ==
                                    "Superadmin" ||
                                Constants.loginResponseModel!.data!.userType ==
                                    "Admin" ||
                                Constants.loginResponseModel!.data!.userType ==
                                    "Business Unit Manager" ||
                                Constants.loginResponseModel!.data!.userRoles!
                                    .contains("Garden"))) ||
                        // External users must have Pool role
                        (Constants.loginResponseModel!.data!.employment ==
                                "External" &&
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Garden"))
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        // img: Assets.inspectionSVG,
                        img: Assets.gardenSVG,
                        title:
                            TranslationService().getTranslation('garden_text'),
                        // 'Departure',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const GardenScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const GardenScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),

                Constants.loginResponseModel!.data!.employment == "Internal" &&
                        (Constants.loginResponseModel!.data!.userType ==
                                "Superadmin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Admin" ||
                            Constants.loginResponseModel!.data!.userType ==
                                "Business Unit Manager" ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Concierge") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Cleaning") ||
                            Constants.loginResponseModel!.data!.userRoles!
                                .contains("Maintenance"))

                    //  ...
                    //     ||
                    // Constants.loginResponseModel!.data!.userRoles!
                    //     .contains("Planner")
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        img: Assets.inspectionSVG,
                        // img: Assets.searchSVG,
                        title: TranslationService()
                            .getTranslation('inspection_text'),
                        // 'Departure',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => const InspectionScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => const InspectionScreen(),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),
                // Constants.loginResponseModel!.data!.employment == "External" &&
                // Constants.loginResponseModel!.data!.userType == "Superadmin" ||
                //         Constants.loginResponseModel!.data!.userType ==
                //             "Admin" ||
                //         Constants.loginResponseModel!.data!.userType ==
                //             "Business Unit Manager" ||
                //         Constants.loginResponseModel!.data!.userRoles!
                //             .contains("Pool") ||
                //         Constants.loginResponseModel!.data!.employment ==
                //             "External"

                (
                        // Internal users must be superadmin/admin/BU manager
                        (Constants.loginResponseModel!.data!.employment ==
                                    "Internal" &&
                                (Constants.loginResponseModel!.data!.userType ==
                                        "Superadmin" ||
                                    Constants.loginResponseModel!.data!
                                            .userType ==
                                        "Admin" ||
                                    Constants.loginResponseModel!.data!
                                            .userType ==
                                        "Business Unit Manager" ||
                                    Constants
                                        .loginResponseModel!.data!.userRoles!
                                        .contains("Pool"))) ||

                            // External users must have Pool role
                            (Constants.loginResponseModel!.data!.employment ==
                                    "External" &&
                                Constants.loginResponseModel!.data!.userRoles!
                                    .contains("Pool")))
                    ? _createTile(
                        isSpace: true,
                        isSVG: true,
                        img: Assets.poolSVG,
                        // img: Assets.searchSVG,
                        title: TranslationService().getTranslation('pool_text'),
                        // 'Departure',
                        onTap: (() {
                          log("activty: +++ $activity");
                          Get.back();
                          if (activity == Activities.home) {
                            Get.to(() => PoolScreen(selectedPropertyID: ""),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          } else {
                            Get.off(() => PoolScreen(selectedPropertyID: ""),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          }
                        }),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _createTile({
    required String img,
    required String title,
    required void Function() onTap,
    required bool isSVG,
    required bool isSpace,
  }) {
    return Padding(
      padding: isSpace == true
          ? const EdgeInsets.only(left: 14.0)
          : const EdgeInsets.all(0),
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -3, horizontal: -4),
        leading: isSVG == true
            ? SvgPicture.asset(
                img,
                width: Get.width * 0.06,
                // ignore: deprecated_member_use
                color: CustomColors.textGrey,
              )
            : Image.asset(
                img,
                width: Get.width * 0.06,
                // ignore: deprecated_member_use
              ),
        title: Text(
          title,
          style: TextStyle(
            color: CustomColors.textGrey,
            fontSize: Get.width < 600 ? Get.width * 0.042 : Get.width * 0.03,
            fontWeight: FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

Widget szbx() {
  return const SizedBox();
}

// late SharedPreferences prefs;
Rx<CheckInResponseModel> checkInResponseModel = CheckInResponseModel().obs;

checkIfClockedIn(activity) async {
  SharedPreferences prefs;
  prefs = await SharedPreferences.getInstance();
  var authToken = prefs.getString(Constants.AUTH_TOKEN);

  log("auth token: $authToken");
  Map<String, String> data = {
    "date": DateTime.now().toString(),
  };

  callWebApiWTDrawer(ApiUrls.checkInPage, data,
      onResponse: (http.Response response) async {
    var responseJson = jsonDecode(response.body);

    try {
      checkInResponseModel.value = CheckInResponseModel.fromJson(responseJson);

      checkInResponseModel.value.message == null ||
              checkInResponseModel.value.message == ""
          ? const SizedBox()
          : Utils.showToast("${checkInResponseModel.value.message}");
      Constants.appbarHeading.value =
          checkInResponseModel.value.data?.isUserClockIn == true
              ? TranslationService().getTranslation('clock_out_text')
              : TranslationService().getTranslation('clock_in_text');

      log(" Constants.appbarHeading.value:: ${Constants.appbarHeading.value}");
      log("drawer---------------------------------------------------------");
      log("is clocked in ${checkInResponseModel.value.data?.isUserClockIn}");
      log("drawer---------------------------------------------------------");
    } catch (e) {
      e.printError();
      e.printInfo();

      log(e.toString());
    }

    log("drawer %%%%%%%%%%%%%%%%%%%% ");
  }, token: authToken);
}

enum Activities {
  gardenForm,
  poolList,
  newClaim,
  expenses,
  inspectionForm,
  poolForm,
  inspectionReview,
  home,
  checkINProgress,
  checkINPrevious,
  checkOutPrevious,
  checkOutProgress,
  electricityCheckOut,
  checkIN,
  electricity,
  latestBookings,
  noticeBoard,
  preArrivalInformation,
  inAndOut,
  groupChat,
  partnerBookings,
  checkIn,
  checkOut,
  guestSatisfaction,
  properties,
  inventoryList,
  inventoryRequest,
  discardRequest,
  inventoryLogs,
  calendar,
  directBooking,
  electricityMeterDone,
  qualityControl,
  cleaning,
  completeCleaning,
  privacyPolicy,
  arrival,
  meterLocation,
  departure,
  whatsappManager,
  checkINControl,
  villaReminder,
  satisfaction,
  approveDiscount,
}
 */