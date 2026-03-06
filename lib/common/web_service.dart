import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/load_manager.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:surveyor_app_planzaa/pages/login_page.dart';

import 'app_exception.dart';
import 'constants.dart';
import 'utils.dart';

Future<dynamic> callWebApi(TickerProvider? tickerProvider, String url, Map data,
    {required Function onResponse,
    Function? onError,
    String? token,
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT(/* tickerProvider */);
  // if (showLoader) Utils.showLoaderDialog(tickerProvider);
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    if (kDebugMode) {
      print('request data: ${json.encode(data)}');
    }

    Map<String, String> headers = <String, String>{
      "Accept": "application/json",
      // "Content-Type": "application/x-www-form-urlencoded"
      // 'Content-Type': 'multipart/form-data; charset=UTF-8'
      'Content-Type': 'application/json; charset=UTF-8',
    };
    headers.addIf(token?.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(data));

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast( 'No Internet Connection'  );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast( 'Something went wrong' );
    LoaderManager.hideLoader();
    return;
  }
}

Future<dynamic> callWebApiWT(
    /* TickerProvider tickerProvider,  */ String url, Map data,
    {required Function onResponse,
    Function? onError,
    String? token,
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT();
  // if (showLoader) Utils.showLoaderDialog(tickerProvider);
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    if (kDebugMode) {
      print('request data: ${json.encode(data)}');
    }

    Map<String, String> headers = <String, String>{
      // 'Content-Type': 'application/json'
      'Content-Type': 'application/json; charset=UTF-8',
    };
    headers.addIf(token?.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(data));

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast( 'No Internet Connection' );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast( 'Something went wrong' );
    LoaderManager.hideLoader();
    return;
  }
}

Future<dynamic> callWebApiWTDrawer(
    /* TickerProvider tickerProvider,  */ String url, Map data,
    {required Function onResponse,
    Function? onError,
    String? token,
    bool showLoader = false,
    bool hideLoader = false}) async {
  // if (showLoader) LoaderManager.showLoaderDialogNewWT();
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    if (kDebugMode) {
      print('request data: ${json.encode(data)}');
    }

    Map<String, String> headers = <String, String>{
      // 'Content-Type': 'application/json'
      'Content-Type': 'application/json; charset=UTF-8',
    };
    headers.addIf(token?.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(data));

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast( 'No Internet Connection' );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast( 'Something went wrong' );
    // LoaderManager.hideLoader();
    return;
  }
}

_returnResponse(http.Response response, Function onResponse, Function onError,
    bool hideLoader) async {
  if (kDebugMode) {
    print('response code:${response.statusCode}');
  }
  if (kDebugMode) {
    print('response :${response.body}');
  }
  Utils.print('response :$response');
  Map responseJson = {};
  try {
    responseJson = jsonDecode(response.body);
  } catch (exception) {
    responseJson['message'] =  "Something went wrong" 
       ;
    if (hideLoader) LoaderManager.hideLoader();

    if (kDebugMode) {
      print(exception.toString());
    }
  }
  switch (response.statusCode) {
    case 200:
      if (hideLoader) LoaderManager.hideLoader();
      onResponse(response);
      return 'responseJson';
    case 201:
      if (hideLoader) LoaderManager.hideLoader();
      onResponse(response);
      return 'responseJson';
    // case 204:
    //   if (hideLoader) Utils.hideLoader();
    //   // response.body = [];
    //   // onResponse(response);
    //   return 'responseJson';
    case 400:
      onError();

      LoaderManager.hideLoader();
      Utils.showToast(responseJson['message']);
      // Utils.showToast(responseJson['message']['email']);

      // Utils.showToast(responseJson['message']['password']);
      // Utils.showToast(responseJson['message']);

      throw BadRequestException(response.body.toString());

    case 404:
      onError();

      LoaderManager.hideLoader();
      Utils.showToast(responseJson['message']);

      throw InvalidInputException(response.body.toString());
    case 401:
      onError();
      LoaderManager.hideLoader();
      Utils.showToast(responseJson['message']);
      await SharedPreferences.getInstance()
          .then((value) => value.setInt(Constants.IS_LOGGED_IN, 0));
      Get.offUntil(CupertinoPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
      throw InvalidInputException(responseJson.toString());
    case 403:
      onError();

      LoaderManager.hideLoader();
      Utils.showToast(
           'Your session has expired, please login again!' );
      await SharedPreferences.getInstance()
          .then((value) => value.setInt(Constants.IS_LOGGED_IN, 0));
      Get.offUntil(CupertinoPageRoute(builder: (context) => const LoginPage()),
          (route) => false);

      throw UnauthorisedException(response.body.toString());
    case 500:
    default:
      Utils.showToast(responseJson['message']);

      onError();

      LoaderManager.hideLoader();
      throw FetchDataException(

        "Error occured while communication with server with statuscode : ${response.statusCode}");
  }
}

Future<dynamic> callWebApiGet(TickerProvider? tickerProvider, String url,
    {required Function onResponse,
    Function? onError,
    String token = "",
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT(/* tickerProvider */);
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    // print('request data: ${json.encode(data)}');

    Map<String, String> headers = <String, String>{
      'Content-type': 'application/json',
      //  'Accept': 'application/json',
      //  'Content-Type': 'application/json; charset=UTF-8',
      // 'Content-Type': 'application/json'
      //   "charset=utf-8"
    };
    headers.addIf(token.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.get(
      Uri.parse(url),
      headers: headers,

      // data:
      // data : json.encode(data)
      // body: json.encode(data)
    );

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast( 'No Internet Connection' );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast('Something went wrong');
    LoaderManager.hideLoader();
    return;
  }
}



Future<dynamic> callWebApiGetWT(String url,
    {required Function onResponse,
    Function? onError,
    String token = "",
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT();
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    // print('request data: ${json.encode(data)}');

    Map<String, String> headers = <String, String>{
      'Content-type': 'application/json',
      //  'Accept': 'application/json',
      //  'Content-Type': 'application/json; charset=UTF-8',
      // 'Content-Type': 'application/json'
      //   "charset=utf-8"
    };
    headers.addIf(token.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.get(
      Uri.parse(url),
      headers: headers,

      // data:
      // data : json.encode(data)
      // body: json.encode(data)
    );

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast( 'No Internet Connection' );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast('Something went wrong');
    LoaderManager.hideLoader();
    return;
  }
}

Future<File> loadPdfFromNetwork(
    TickerProvider tickerProvider, String url, Map data,
    {required Function onResponse,
    Function? onError,
    String token = "",
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT(/* tickerProvider */);
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    if (kDebugMode) {
      print('request data: ${json.encode(data)}');
    }

    Map<String, String> headers = <String, String>{
      'Content-type': 'application/json',
      //  'Accept': 'application/json',
      //  'Content-Type': 'application/json; charset=UTF-8',
      // 'Content-Type': 'application/json'
      //   "charset=utf-8"
    };
    headers.addIf(token.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.get(
      Uri.parse(url),
      headers: headers,

      // data:
      // data : json.encode(data)
      // body: json.encode(data)
    );

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast( 'No Internet Connection' );
    LoaderManager.hideLoader();
    return File("");
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast('Something went wrong');
    LoaderManager.hideLoader();
    return File("");
  }
}

Future<dynamic> callWebApiPut(
    TickerProvider tickerProvider, String url, Map data,
    {required Function onResponse,
    Function? onError,
    String token = "",
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT(/* tickerProvider */);
  try {
    if (kDebugMode) {
      print('request url: $url');
    }
    if (kDebugMode) {
      print('request data: ${json.encode(data)}');
    }

    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Content-Type': 'application/json'
      //   "charset=utf-8"
    };
    headers.addIf(token.isNotEmpty, "Authorization", "Bearer $token");
    if (kDebugMode) {
      print('headers: ${json.encode(headers)}');
    }

    final http.Response response = await http.put(Uri.parse(url),
        headers: headers, body: json.encode(data));

    return _returnResponse(response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast('No Internet Connection' );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast('Something went wrong');
    LoaderManager.hideLoader();
    return;
  }
}

Future<dynamic> callMultipartWebApi(TickerProvider tickerProvider, String url,
    Map<String, String> data, List<http.MultipartFile> files,
    {required Function onResponse,
    Function? onError,
    required String token,
    bool showLoader = true,
    bool hideLoader = true}) async {
  if (showLoader) LoaderManager.showLoaderDialogNewWT(/* tickerProvider */);

  var request = http.MultipartRequest("POST", Uri.parse(url));

  Map<String, String> headers = <String, String>{
    'Content-Type': 'application/json',
    //  "charset=utf-8"
    // 'Authorization': 'Bearer $token'
  };
// "Content-Type": "application/x-www-form-urlencoded"

  headers.addIf(token.isNotEmpty, "Authorization", "Bearer $token");

  if (kDebugMode) {
    print('request url: $url');
  }
  if (kDebugMode) {
    print('request data: ${json.encode(data)}');
  }
  if (kDebugMode) {
    print('headers: ${json.encode(headers)}');
  }

  request.headers.addAll(headers);

  try {
    request.fields.addAll(data);
    for (http.MultipartFile file in files) {
      request.files.add(file);
      if (kDebugMode) {
        print('request file: ${file.filename}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error adding request : $e");
    }
    LoaderManager.hideLoader();
  }

  try {
    var response = await request.send();
    return returnMutipartResponse(
        response, onResponse, onError ?? () {}, hideLoader);
  } on SocketException catch (e) {
    if (kDebugMode) {
      // ignore: no_wildcard_variable_uses
      print(e.toString());
    }
    if (onError != null) {
      onError();
    }
    Utils.showToast('No Internet Connection' );
    LoaderManager.hideLoader();
    return;
  } catch (e) {
    if (onError != null) {
      onError();
    }
    if (kDebugMode) {
      print(e.toString());
    }
    Utils.showToast('Something went wrong');
    LoaderManager.hideLoader();
  }
}




returnMutipartResponse(http.StreamedResponse response, Function onResponse,
    Function onError, bool hideLoader) async {
  var resp = await response.stream.transform(utf8.decoder).join();
  if (kDebugMode) {
    print('response code:${response.statusCode}');
  }

  Map responseJson = {};
  try {
    responseJson = json.decode(resp);
    if (kDebugMode) {
      print('response :$responseJson');
    }
  } catch (exception) {
    responseJson['message'] = 'Something went wrong';
    if (kDebugMode) {
      print(exception.toString());
    }
    if (hideLoader) LoaderManager.hideLoader();
  }

  // Include the status code in the responseJson map
  responseJson['statusCode'] = response.statusCode;

  switch (response.statusCode) {
    case 200:
      if (hideLoader) LoaderManager.hideLoader();
      onResponse(responseJson);
      return responseJson;
    case 400:
      onError();
      LoaderManager.hideLoader();
      Utils.showToast(responseJson['message']);
      throw BadRequestException(responseJson.toString());
    case 404:
      onError();
      LoaderManager.hideLoader();
      Utils.showToast(responseJson['message']);
      throw InvalidInputException(responseJson.toString());
    case 401:
      onError();
      LoaderManager.hideLoader();
      Utils.showToast(responseJson['message']);
      throw InvalidInputException(responseJson.toString()); 
    case 403:
      onError();
      LoaderManager.hideLoader();
      Utils.showToast( 'Your session has expired, please login again!' );
      await SharedPreferences.getInstance()
          .then((value) => value.setInt(Constants.IS_LOGGED_IN, 0));
      Get.offUntil(CupertinoPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
      throw UnauthorisedException(responseJson.toString());
    case 500:
    default:
      Utils.showToast(responseJson['message']);
      onError();
      LoaderManager.hideLoader();
      throw FetchDataException(
          'ERROR OCCURED WHILE COMMUNICATION WITH SERVER WITH STATUSCODE : ${response.statusCode}');
  }
}
