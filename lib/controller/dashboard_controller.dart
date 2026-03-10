import 'dart:convert';
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

class DashboardController extends GetxController {
  final TickerProvider _tickerProvider;
  DashboardController(this._tickerProvider);

 var currentIndex = 0.obs;
 var pendingSyncBookings = <String>{}.obs; 

  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }
  var jobList = <JobRequest>[].obs;
  String? authToken;
  var remainingTimeMap = <int, Rx<Duration>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
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
          DashboardResponseModel model = DashboardResponseModel.fromJson(responseJson);
         if (model.status == "success") {
  jobList.value = model.data?.jobRequest ?? [];
  
  // ✅ Debug — remove after testing
  for (var job in jobList) {
    Utils.print("JOB: ${job.bookingNo} STATUS: '${job.status}'");
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
      JobStatusResponseModel result = JobStatusResponseModel.fromJson(jsonData);

      if (result.status == "success") {
        Utils.showToast(result.message ?? "");

        int index = jobList.indexWhere((job) => job.projectId == projectId);
        if (index != -1) {
          jobList[index].status = status;

          if (status == "accepted") {
            jobList[index].acceptedAt = DateTime.now().toString();
            startCountdown(jobList[index]);
          }
        }
        jobList.refresh();

        // ✅ Navigate to Work page when Inprogress tapped
        if (status == "pending") {
          await Get.to(() => Work(
            projectId: projectId.toString(),
            bookingNo: bookingNo,
            acceptedAt: index != -1 ? jobList[index].acceptedAt : null,
          ));
          // ✅ Refresh after returning from Work page
          fetchDashboard();
        }

      } else if (result.error == "already_taken") {
        // ✅ Only show error when ACCEPTING — not when pressing Inprogress
        if (status == "accepted") {
          Utils.showToast(result.message.toString());
          fetchDashboard();
        } else if (status == "pending") {
          // This surveyor already owns it — just navigate
          int index = jobList.indexWhere((job) => job.projectId == projectId);
          await Get.to(() => Work(
            projectId: projectId.toString(),
            bookingNo: bookingNo,
            acceptedAt: index != -1 ? jobList[index].acceptedAt : null,
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
}