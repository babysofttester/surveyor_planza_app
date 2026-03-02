import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils {
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showToast(String text, [Color? bgColor]) {
    if (!kIsWeb) {
      Fluttertoast.cancel();
    }

    if (Platform.isWindows) {
      Get.rawSnackbar(
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
          borderRadius: 0,
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          messageText: Utils.textView(text, 16, Colors.white, FontWeight.bold),
          backgroundColor: Colors.grey.shade900);
    } else {
      Fluttertoast.showToast(
          msg: text,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey.shade900,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  static void print(message) {
    if (!kReleaseMode) {
      debugPrint(message.toString());
    }
  }

  static String formatDateN(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('EEE d MMM yy').format(dateTime);
    return formattedDate;
  }

  // static String formatDate(String dateTimeString) {
  //   // Parse the input string to DateTime object
  //   DateTime dateTime = DateTime.parse(dateTimeString);

  //   // Use DateFormat to format the date into "Friday 13 December"
  //   String formattedDate = DateFormat('EEEE d MMMM').format(dateTime);

  //   return formattedDate;
  // }

  static String formatTime(String dateTimeString) {
    // Parse the input string to DateTime object considering the time zone
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Convert the DateTime object to the local time zone
    dateTime = dateTime.toLocal();

    // Use DateFormat to format the time into 12-hour format (AM/PM)
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return formattedTime;
  }

  /*  static String formatTime(String dateTimeString) {
    // Parse the input string to DateTime object considering the time zone
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Ensure the DateTime object is in your local time zone
    // dateTime = dateTime.toLocal();

    // Use DateFormat to format the time into 12-hour format (AM/PM)
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return formattedTime;
  } */

  static Widget toastWidget(text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check),
          const SizedBox(
            width: 12.0,
          ),
          Text(text),
        ],
      ),
    );
  }

  static bool isValidEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(p);

    return regExp.hasMatch(email);
  }

  static String getMonth(String date) {
    int year = int.parse(date.split('-')[0]);
    int month = int.parse(date.split('-')[1]);
    int day = int.parse(date.split('-')[2]);

    DateTime a = DateTime(year, month, day);

    return DateFormat('MMM').format(a);
  }

  static String getYear(String date) {
    int year = int.parse(date.split('-')[0]);
    int month = int.parse(date.split('-')[1]);
    int day = int.parse(date.split('-')[2]);

    DateTime a = DateTime(year, month, day);

    return DateFormat('yyyy').format(a);
  }

  static String getDate(String date) {
    int year = int.parse(date.split('-')[0]);
    int month = int.parse(date.split('-')[1]);
    int day = int.parse(date.split('-')[2]);

    DateTime a = DateTime(year, month, day);

    return DateFormat('dd').format(a);
  }

  static String getDay(String date) {
    int year = int.parse(date.split('-')[0]);
    int month = int.parse(date.split('-')[1]);
    int day = int.parse(date.split('-')[2]);

    DateTime a = DateTime(year, month, day);

    return DateFormat('EEE').format(a);
  }

  static String htmlEntityToUnicodeCharacter(String htmlEntity) {
    if (htmlEntity.isEmpty) {
      return '👤';
    }

    // Regular expression to match hexadecimal HTML entities like &#x1F1EF;
    final regex = RegExp(r'&#x([0-9A-Fa-f]+);');

    // Replace all matched HTML entities with their corresponding Unicode characters
    String result = htmlEntity.replaceAllMapped(regex, (match) {
      String hexCode = match.group(1)!; // Extract the hex code
      int codePoint = int.parse(hexCode, radix: 16); // Convert to code point
      return String.fromCharCode(codePoint); // Return the Unicode character
    });

    return result;
  }

  static Future<bool> isNetworkConnected() async {
    try {
      await InternetAddress.lookup('google.com');
      return true;
    } on SocketException catch (_) {
      Utils.showToast('No Internet Connection', Colors.red);
      return false;
    } catch (e) {
      Utils.showToast('No Internet Connection', Colors.red);
      return false;
    }
  }

/*   static void showLoaderDialogNew(TickerProvider tickerProvider) {
    EasyLoading.show(dismissOnTap: false, status: 'loading...');
  } */

/*   static void showLoaderDialogNewWT() {
    EasyLoading.show(dismissOnTap: false, status: 'loading...');
  } */

/* 
static bool _isLoaderVisible = false;

static void showLoaderDialogNewWT() {
  if (_isLoaderVisible) {
    print("Loader is already visible");
    return;
  }

  // Ensure any existing overlay is removed
  hideLoader();

  OverlayState? overlayState = Constants.navigatorKey.currentState?.overlay;

  if (overlayState != null) {
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.1),
            ),
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(overlayEntry);
    _currentOverlayEntry = overlayEntry;
    _isLoaderVisible = true; // Mark the loader as visible
  }
}

static void hideLoader() {
  if (_currentOverlayEntry != null) {
    try {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
      _isLoaderVisible = false; // Mark the loader as hidden
      print("Overlay removed successfully");
    } catch (e) {
      print("Error removing overlay: $e");
    }
  } else {
    print("No overlay to remove");
  }
}
 */

  static void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Widget textView(
      String text, double fontSize, Color textColor, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
          color: textColor, fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  static Widget textViewAlign(String text, double fontSize, Color textColor,
      FontWeight fontWeight, TextAlign textAlign) {
    return Text(
      text,
      textAlign: textAlign,
      softWrap: true,
      style: TextStyle(
          color: textColor, fontSize: fontSize, fontWeight: fontWeight),
    );
  }
    static Widget textViewStyle(
      String text, double fontSize, Color textColor, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
          color: textColor, fontSize: fontSize, fontWeight: fontWeight, fontStyle: FontStyle.italic),
    );
  }
  static Widget textViewPro(
  String text,
  double fontSize,
  Color color,
  FontWeight fontWeight, {
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) {
  return Text(
    text,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    ),
  );
}


}
