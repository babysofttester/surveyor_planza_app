import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';

class StatusUpdateController extends GetxController {
  final TickerProvider tickerProvider;

  StatusUpdateController(this.tickerProvider);

  Future<bool> updateOnlineStatus(int status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(Constants.AUTH_TOKEN);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.statusUpdate), 
      );

      request.headers['Authorization'] = 'Bearer ${authToken ?? ""}';
      request.fields['status'] = status.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status update response: ${response.body}");

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['status'] == "success";

    } catch (e) {
      print("Status update error: $e");
      return false;
    }
  }
}