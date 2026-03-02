// import 'package:zego_zimkit/zego_zimkit.dart';

// class ZegoService {

//   static Future<bool> login({
//     required String userID,
//     required String userName,
//   }) async {
//     final errorCode = await ZIMKit().connectUser(
//       id: userID,
//       name: userName,
//       avatarUrl: 'https://robohash.org/$userID.png',
//     );

//     return errorCode == 0;
//   }

//   static Future<void> logout() async {
//     await ZIMKit().disconnectUser();
//   }
// }


// // import 'dart:async';
// // import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// // import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// // import 'package:zego_zimkit/zego_zimkit.dart';

// // class ZegoService {
// //   static const int appID = 1957375325;
// //   static const String appSign =
// //       "7d03a650bc971fe2ceb1289630ffd21995eed12c056096458af6d3f1fa0341f7";

// //   static bool _isInitialized = false;
// //   static bool _isLoggedIn = false;

// //   static StreamSubscription? _connectionSubscription;

// //   static Future<void> init({
// //     required String userID,
// //     required String userName,
// //   }) async {
// //     if (_isInitialized && _isLoggedIn) return;

// //     print("🚀 ZEGO INIT START");

// //     await ZegoUIKitPrebuiltCallInvitationService().init(
// //       appID: appID,
// //       appSign: appSign,
// //       userID: userID,
// //       userName: userName,
// //       plugins: [ZegoUIKitSignalingPlugin()],
// //     );

// //     await ZIMKit().init(
// //       appID: appID,
// //       appSign: appSign,
// //     );

// //     final completer = Completer<void>();

// //     _connectionSubscription?.cancel();
// //     _connectionSubscription =
// //         ZIMKit().getConnectionStateChangedEventStream().listen((event) {
// //       print("🔥 ZIM STATE: ${event.state}");

// //       if (event.state == ZIMConnectionState.connected) {
// //         _isLoggedIn = true;
// //         print("✅ ZIM CONNECTED SUCCESSFULLY");
// //         if (!completer.isCompleted) {
// //           completer.complete();
// //         }
// //       }

// //       if (event.state == ZIMConnectionState.disconnected) {
// //         _isLoggedIn = false;
// //       }
// //     });

// //     await ZIMKit().connectUser(
// //       id: userID,
// //       name: userName,

// //     );

// //     // 🔥 WAIT until connected
// //     await completer.future;

// //     _isInitialized = true;
// //   }

// // /* 
// //   static Future<void> init({
// //     required String userID,
// //     required String userName,
// //   }) async {
// //     if (_isInitialized && _isLoggedIn) return;

// //     print("🚀 ZEGO INIT START");

// //     /// 1️⃣ Call Invitation Init
// //     await ZegoUIKitPrebuiltCallInvitationService().init(
// //       appID: appID,
// //       appSign: appSign,
// //       userID: userID,
// //       userName: userName,
// //       plugins: [ZegoUIKitSignalingPlugin()],
// //     );

// //     /// 2️⃣ ZIM Init
// //     await ZIMKit().init(
// //       appID: appID,
// //       appSign: appSign,
// //     );

// //     /// 3️⃣ Listen for connection state
// //     _connectionSubscription?.cancel();
// //     _connectionSubscription =
// //         ZIMKit().getConnectionStateChangedEventStream().listen((event) {
// //       print("🔥 ZIM STATE: ${event.state}");

// //       if (event.state == ZIMConnectionState.connected) {
// //         _isLoggedIn = true;
// //         print("✅ ZIM CONNECTED SUCCESSFULLY");
// //       }

// //       if (event.state == ZIMConnectionState.disconnected) {
// //         _isLoggedIn = false;
// //         print("❌ ZIM DISCONNECTED");
// //       }
// //     });

// //     /// 4️⃣ Connect User
// //     await ZIMKit().connectUser(
// //       id: userID,
// //       name: userName,
// //     );

// //     _isInitialized = true;
// //   }
// //  */
// //   static bool get isReady => _isLoggedIn;

// //   static Future<void> unInit() async {
// //     print("🛑 ZEGO UNINIT");

// //     await ZegoUIKitPrebuiltCallInvitationService().uninit();
// //     await ZIMKit().disconnectUser();
// //     await ZIMKit().uninit();

// //     await _connectionSubscription?.cancel();

// //     _isInitialized = false;
// //     _isLoggedIn = false;
// //   }
// // }
