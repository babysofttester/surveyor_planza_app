// ignore_for_file: constant_identifier_names


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/modal/login_response_model.dart';
// import 'package:miracle_manager/model/login_response_model.dart';
// import 'package:miracle_manager/model/transalation_response_model.dart';

class Constants {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String KEY_LOGIN_RESPONSE = 'loginResponse';
  static const String IS_LOGGED_IN = 'isLoggedIn';
  static const String REMEMBER_ME = 'rememberMe';
  static const String KEY_USER_NAME = 'userName';
  static const String KEY_USER_PASSWORD = 'userPassword';
  static const String fcmToken = 'fcmToken';
  static const String deviceID = 'deviceId';
  static const String KEY_REMEMBER_ME = 'keyRememberMeBool';
  static const String AUTH_TOKEN = 'auth_token';
  static const String user = 'user';
  static int isSubscribed = 0;
  static String userId = '';
  static String userImage = '';
  static String userName = '';
  static int seenByUser = 0;
  static String startTimeSet = "";
  static String endTimeSet = "";
  static String clockInDateTime = "";
  static RxBool clockOutText = false.obs;
  static late LoginResponseModel? loginResponseModel;
  static String workingTime = "workingTime";
  static String workingDate = "workingDate";
  static const platform = MethodChannel('com.example.location_service');
  static RxString appbarHeading = "Clock-in".obs;
  static RxBool dayOff = false.obs;
  static RxBool isSickLeave = false.obs;
}
