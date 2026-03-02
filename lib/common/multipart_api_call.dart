
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:surveyor_app_planzaa/common/load_manager.dart';

/// Generic multipart API call function
Future<void> callMultipartWebApi(
  TickerProvider tickerProvider,
  String url,
  Map<String, String> bodyFields,
  List<File> files, {
  required void Function(http.Response response) onResponse,
  required String token,
}) async {
  try {
    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);

    // Add headers
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // Add fields
    bodyFields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Attach files if any
    for (var file in files) {
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'files[]', // key expected by server (change as needed)
        stream,
        length,
        filename: file.path.split("/").last,
      );
      request.files.add(multipartFile);
    }

    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (kDebugMode) {
      print("Multipart API Response: ${response.statusCode}");
      print("Response Body: ${response.body}");
    }

    onResponse(response);
  } catch (e, stacktrace) {
    debugPrint("Multipart API Call failed: $e");
    debugPrint(stacktrace.toString());
    LoaderManager.hideLoader();
  }
}
