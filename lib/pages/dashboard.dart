import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/modal/dashboard_response_model.dart';
import 'package:surveyor_app_planzaa/pages/work.dart';
import '../controller/dashboard_controller.dart';

class Dashboard extends StatefulWidget {
   final Function(int)? onTabChange;
  const Dashboard({super.key, this.onTabChange});
 
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {


late DashboardController dashboardController;
  @override
  void initState() {
    super.initState();
    dashboardController = Get.put(DashboardController(this));
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
              const SizedBox(height: 15),

              
              Expanded(
                child: Obx(() {

  // if (dashboardController == null) {
  //   return const Center(child: CircularProgressIndicator());
  // }

  if (dashboardController.jobList.isEmpty) { 
    return const Center(child: Text("No Jobs Available"));
  }

  return ListView.builder(
    itemCount: dashboardController.jobList.length,
    itemBuilder: (context, index) {
      final job = dashboardController.jobList[index];
      return _jobCard(job, dashboardController);
    },
  );
}),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobCard(JobRequest job, DashboardController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Utils.textView(
      "Job ID: ${job.bookingNo ?? ''}",
      Get.width * 0.045,
      CustomColors.black,
      FontWeight.w700,
    ),

  
    if (job.status == "accepted")
  Obx(() {
    final remaining = controller
        .remainingTimeMap[job.projectId ?? 0]
        ?.value;

    if (remaining == null) {
      return const SizedBox();
    }

    if (remaining.inSeconds <= 0) {
      return GestureDetector(
          onTap: () {
            Utils.showToast("This job has expired.");
          },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey, 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.timer_off,
                  size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                "Expired",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

   
    String twoDigits(int n) =>
        n.toString().padLeft(2, '0');

    final hours = twoDigits(remaining.inHours);
    final minutes =
        twoDigits(remaining.inMinutes.remainder(60));
    final seconds =
        twoDigits(remaining.inSeconds.remainder(60));

    return GestureDetector( 
      onTap: () {  
     //     widget.onTabChange?.call(1);  
 Get.to(() => Work(
  projectId: job.projectId!.toString(),
  bookingNo: job.bookingNo!,
  acceptedAt: job.acceptedAt,   
));
          
      }, 
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: CustomColors.boxColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.timer,
                size: 16, color: CustomColors.white),
            const SizedBox(width: 4),
            Text(
              "$hours:$minutes:$seconds",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }),
  ], 
),
       
          SizedBox(height: Get.height * 0.005),

           Utils.textView(
                         "₹${job.earningAmount ?? 0}",
                          Get.width * 0.045,
                          CustomColors.black,
                          FontWeight.w700, 
                        ),

           SizedBox(height: Get.height * 0.005),

          
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 20, color: CustomColors.boxColor),
              const SizedBox(width: 4),
              Utils.textView(
                          "${job.city ?? ''}, ${job.state ?? ''}",
                          Get.width * 0.033,
                          CustomColors.black,
                          FontWeight.w400, 
                        ),
            
            ],
          ),

          const SizedBox(height: 12),

       
_buildActionButtons(job), 
         
       
       
        ],
      ),
    );
  }

  Widget _buildActionButtons(JobRequest job) {


  if (job.status == "rejected") {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: null,
        child: Utils.textView(
          "Rejected",
          Get.width * 0.035,
          CustomColors.white,
          FontWeight.w700,
        ),
      ),
    );
  }


  if (job.status == "accepted") {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.btnColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          dashboardController.updateJobStatus(
            job.projectId ?? 0,
            job.bookingNo ?? "",
            "pending",
          );
        },
        child: Utils.textView(
          "Inprogress",
          Get.width * 0.035,
          CustomColors.white,
          FontWeight.w700,
        ),
      ),
    );
  }

 
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F3E8C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            dashboardController.updateJobStatus(
              job.projectId ?? 0,
              job.bookingNo ?? "",
              "accepted",
            );
          },
          child: Utils.textView(
            "Accept",
            Get.width * 0.035,
            CustomColors.white,
            FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.btnColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            dashboardController.updateJobStatus(
              job.projectId ?? 0,
              job.bookingNo ?? "",
              "rejected",
            );
          },
          child: Utils.textView(
            "Reject",
            Get.width * 0.035,
            CustomColors.white,
            FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
}



/*
//in dashboard screen 
online - 1
offline -0
 if online then show projects which are come from customer app
 if offline then projects are not come 

 
*/