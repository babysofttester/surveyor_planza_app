// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:miracle_manager/common/constants.dart';

// class LoaderManager {
//   static OverlayEntry? _currentOverlayEntry; // Declare the variable
//   static bool _isLoaderVisible = false;

// // static OverlayEntry? _currentOverlayEntry;
// // static bool _isLoaderVisible = false;

//   static void showLoaderDialogNewWT() {
//     if (_isLoaderVisible) {
//       print("Loader is already visible");
//       return;
//     }

//     print("Attempting to show loader...");
//     hideLoader(); // Ensure no existing loader

//     OverlayState? overlayState = Constants.navigatorKey.currentState?.overlay;

//     if (overlayState != null) {
//       final overlayEntry = OverlayEntry(
//         builder: (context) {
//           return Stack(
//             children: [
//               ModalBarrier(
//                 dismissible: false,
//                 color: Colors.black.withOpacity(0.1),
//               ),
//               Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor:
//                       AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
//                 ),
//               ),
//             ],
//           );
//         },
//       );

//       overlayState.insert(overlayEntry);
//       _currentOverlayEntry = overlayEntry;
//       _isLoaderVisible = true;
//       print("Loader is now visible");
//     } else {
//       print("OverlayState is null");
//     }
//   }

//   static void hideLoader() {
//     print("Attempting to hide loader...");
//     if (_currentOverlayEntry != null) {
//       try {
//         _currentOverlayEntry!.remove();
//         _currentOverlayEntry = null;
//         _isLoaderVisible = false;
//         print("Overlay removed successfully");
//       } catch (e) {
//         print("Error removing overlay: $e");
//       }
//     } else {
//       print("No overlay to remove");
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoaderManager {
  // Show the loader
  static void showLoaderDialogNewWT() {
    // FocusManager.instance.primaryFocus?.unfocus();
    if (FocusManager.instance.primaryFocus != null &&
        FocusManager.instance.primaryFocus!.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    EasyLoading.instance
      ..maskType = EasyLoadingMaskType.black // Blocks interactions
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..backgroundColor = Colors.transparent.withOpacity(1)
      ..textColor = Colors.white;

    EasyLoading.show(status: 'Loading...');
  }

  // Hide the loader
  static void hideLoader() {
    EasyLoading.dismiss();
  }
}
