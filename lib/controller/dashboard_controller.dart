import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/constants.dart';
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/dashboard_response_model.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/modal/job_status_reponse_model.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';
import 'package:surveyor_app_planzaa/pages/work.dart';
import 'package:surveyor_app_planzaa/services/offlinework_queue_services.dart';
import 'package:surveyor_app_planzaa/controller/eraning_controller.dart';
import 'package:surveyor_app_planzaa/controller/workHistory_controller.dart';

class DashboardController extends GetxController {
  final TickerProvider _tickerProvider;
  DashboardController(this._tickerProvider);

  var currentIndex = 0.obs;
  var pendingSyncBookings = <String>{}.obs;
  var _locallyRemovedBookings = <String>{};

  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }

  var jobList = <JobRequest>[].obs;
  String? authToken;
  var remainingTimeMap = <int, Rx<Duration>>{}.obs;

  StreamSubscription? _connectivitySubscription;
  Function(int)? onTabChange;

  @override
  void onInit() {
    super.onInit();
    _init();
    // _locallyRemovedBookings;
    //loadToken();
 
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        _autoSyncOfflineQueue();
      }
    });
  } 

Future<void> _init() async {
  await _loadRemovedBookings(); 
  await loadToken();
 
}

Future<void> _loadRemovedBookings() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getStringList('removed_bookings') ?? [];
  _locallyRemovedBookings = saved.toSet();
  print(" Loaded removed bookings: $_locallyRemovedBookings"); 
}


Future<void> _saveRemovedBookings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('removed_bookings', _locallyRemovedBookings.toList());
  print('_locallyRemovedBookings: ${_locallyRemovedBookings.toList()}');
}


void removeJobLocally(String bookingNo, int projectId) {
  _locallyRemovedBookings.add(bookingNo);
  _saveRemovedBookings();
  jobList.removeWhere((job) => job.bookingNo == bookingNo);
  remainingTimeMap.remove(projectId);
  jobList.refresh();
}


  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

Future<void> loadToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  authToken = prefs.getString(Constants.AUTH_TOKEN);
  if (authToken != null && authToken!.isNotEmpty) {
    fetchDashboard();
  } else {
    Utils.showToast("Session expired. Please login again");
    Get.offAll(() => const LoginPage());
  }
 
}

 void fetchDashboard() {
  callWebApiGet(
    _tickerProvider,
    ApiEndpoints.dashboard,
    onResponse: (http.Response response) async {
      var responseJson = jsonDecode(response.body);
      try {
        DashboardResponseModel model =
            DashboardResponseModel.fromJson(responseJson);
        if (model.status == "success") {
          final allJobs = model.data?.jobRequest ?? [];
          
         
// jobList.value = allJobs
//     .where((job) =>
//         !_locallyRemovedBookings.contains(job.bookingNo ?? ""))
//     .toList();
jobList.value = allJobs
    .where((job) {
      
      if (job.status?.toLowerCase().trim() == "completed") {
        _locallyRemovedBookings.add(job.bookingNo ?? "");
        _saveRemovedBookings();
        return false;
      } 
      return !_locallyRemovedBookings.contains(job.bookingNo ?? "");
    })
    .toList();

          for (var job in allJobs) {
            if (job.status?.toLowerCase().trim() == "completed") {
              remainingTimeMap.remove(job.projectId ?? 0);
            }
          }

          for (var job in jobList) {
            if (job.status == "accepted") {
              startCountdown(job);
            }
          }
          update();
        } else {
          Utils.showToast(model.message.toString());
        }
      } catch (e) {
        Utils.print("DASHBOARD PARSE ERROR: $e");
      }
    },
    token: authToken ?? "",
  );
}


  void startCountdown(JobRequest job) {
    if (job.acceptedAt == null) return;

    DateTime acceptedTime = DateTime.parse(job.acceptedAt!);
    DateTime expiryTime = acceptedTime.add(const Duration(hours: 24));
    Duration remaining = expiryTime.difference(DateTime.now());

    if (remaining.isNegative) {
      remainingTimeMap[job.projectId ?? 0] = Duration.zero.obs;
      return;
    }

    remainingTimeMap[job.projectId ?? 0] = remaining.obs;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      Duration newRemaining = expiryTime.difference(DateTime.now());

      if (newRemaining.isNegative) {
        remainingTimeMap[job.projectId ?? 0]!.value = Duration.zero;
        return false;
      }
      remainingTimeMap[job.projectId ?? 0]!.value = newRemaining;
      return true;
    });
  }

  Future<void> updateJobStatus(
    int projectId,
    String bookingNo,
    String status,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.jobStatus),
      );
      request.fields['project_id'] = projectId.toString();
      request.fields['booking_no'] = bookingNo;
      request.fields['status'] = status;
      request.headers['Authorization'] = 'Bearer ${authToken ?? ""}';
      request.headers['Accept'] = 'application/json';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Utils.print("Job Status Response: ${response.body}");

      var jsonData = jsonDecode(response.body);
      JobStatusResponseModel result =
          JobStatusResponseModel.fromJson(jsonData);

      if (result.status == "success") {
        Utils.showToast(result.message ?? "");

  if (status == "completed") {
    jobList.removeWhere((job) => job.projectId == projectId);
    remainingTimeMap.remove(projectId); 
    jobList.refresh();
    return;
  }

        int index =
            jobList.indexWhere((job) => job.projectId == projectId);
        if (index != -1) {
          jobList[index].status = status;

          if (status == "accepted") {
            jobList[index].acceptedAt = DateTime.now().toString();
            startCountdown(jobList[index]);
          }
        }
        jobList.refresh();

        if (status == "pending") {
          await Get.to(() => Work(
                projectId: projectId.toString(),
                bookingNo: bookingNo,
                acceptedAt:
                    index != -1 ? jobList[index].acceptedAt : null,
              ));
          fetchDashboard();
        }
      } else if (result.error == "already_taken") {
        if (status == "accepted") {
          Utils.showToast(result.message.toString());
          fetchDashboard();
        } else if (status == "pending") {
          int index =
              jobList.indexWhere((job) => job.projectId == projectId);
          await Get.to(() => Work(
                projectId: projectId.toString(),
                bookingNo: bookingNo,
                acceptedAt:
                    index != -1 ? jobList[index].acceptedAt : null,
              ));
          fetchDashboard();
        }
      } else {
        Utils.showToast(result.message ?? "Error");
      }
    } catch (e) {
      Utils.print("updateJobStatus ERROR: $e");
      Utils.showToast("Something went wrong. Try again.");
    }
  }

  void markAsPendingSync(String bookingNo) {
    pendingSyncBookings.add(bookingNo);
    update();
  }

  void clearPendingSync() {
    pendingSyncBookings.clear();
    update();
  }

  // ✅ AUTO SYNC — triggered when internet comes back
  Future<void> _autoSyncOfflineQueue() async {
    final token = authToken;
    if (token == null || token.isEmpty) return;

    final count = await OfflineWorkQueueService.pendingCount();
    if (count == 0) return;

    final isOnline = await _isInternetAvailable();
    if (!isOnline) return;

    await _flushOfflineWorkQueue(token);
  }

 
  Future<void> _flushOfflineWorkQueue(String token) async {
    final pending = await OfflineWorkQueueService.dequeueAll();
    if (pending.isEmpty) return;

    final failed = <Map<String, dynamic>>[];

    for (final item in pending) {
      final bookingNo = item['booking_no'] as String? ?? '' ;
      final projectId = int.tryParse(item['project_id'] as String? ?? '') ?? 0;
      removeJobLocally(bookingNo, projectId);
      
    }

    // for (final item in failed) {
    //   await OfflineWorkQueueService.enqueue(
    //     projectId: item['project_id'] ?? '',
    //     bookingNo: item['booking_no'] ?? '',
    //     length: (item['length'] as num).toDouble(),
    //     breadth: (item['breadth'] as num).toDouble(),
    //     description: item['description'] ?? '',
    //     imagePaths: List<String>.from(item['image_paths'] ?? []),
    //   );
    // }

  if (Get.isRegistered<WorkHistoryController>()) {
    Get.find<WorkHistoryController>().fetchWorkHistory();
  }
  if (Get.isRegistered<EarningController>()) {
    Get.find<EarningController>().fetchEarnings();
  }

  clearPendingSync();

  Get.snackbar(
    "Synced",
    "${pending.length} offline submission(s) uploaded successfully.",
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );

  await Future.delayed(const Duration(milliseconds: 500));
  onTabChange?.call(1);
}
  }

  
  Future<bool> _submitOfflineItem(
      Map<String, dynamic> item, String token) async {
    try {
      final List<String> imagePaths =
          List<String>.from(item['image_paths'] ?? []);

      final existingPaths =
          imagePaths.where((p) => File(p).existsSync()).toList();

      if (imagePaths.isNotEmpty && existingPaths.isEmpty) {
        Utils.print(
            "Skipping offline item [${item['booking_no']}] — all images deleted");
        return true;
      }

      Map<String, dynamic> data = {
        "project_id": item['project_id'] ?? '',
        "booking_no": item['booking_no'] ?? '',
        "length": item['length'].toString(),
        "breadth": item['breadth'].toString(),
        "description": item['description'] ?? '',
      };

      for (int i = 0; i < existingPaths.length; i++) {
        final bytes = await File(existingPaths[i]).readAsBytes();
        final base64Image = base64Encode(bytes);
        final fileName = existingPaths[i].split('/').last;

        data["images[$i][file_name]"] = fileName;
        data["images[$i][file_base64]"] = base64Image;
      }

      final uri = Uri.parse(ApiEndpoints.workUpload);
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      final responseJson = jsonDecode(response.body);
      return response.statusCode == 200 &&
          responseJson['status'] == "success";
    } catch (e) {
      Utils.print("Offline flush error: $e");
      return false;
    }
  }

  Future<bool> _isInternetAvailable() async {
    final result = await Connectivity().checkConnectivity();
    if (result.every((r) => r == ConnectivityResult.none)) return false;
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    
      // final res = await InternetAddress.lookup('google.com')
      //     .timeout(const Duration(seconds: 5));
      // return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    } 
  } 
 