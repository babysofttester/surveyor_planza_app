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
   if (Get.isRegistered<DashboardController>()){
dashboardController = Get.find<DashboardController>();
   }else {
    dashboardController = Get.put(DashboardController(this));
   }
 
}

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            const SizedBox(height: 15),
        
            
            Expanded(
              child: Obx(() {
        
          
          if (dashboardController.jobList.isEmpty) { 
            return const Center(child: Text("No Jobs Available"));
          }
        
              final reversedList = dashboardController.jobList.reversed.toList();
        
          return ListView.builder(
             padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
            itemCount: reversedList.length,
            reverse: false,  
            itemBuilder: (context, index) {
              final job = reversedList[index];
              return _jobCard(job, dashboardController);
            },
          );
        }),
            )
          ],
        ),
      ),
    );
  }

  Widget _jobCard(JobRequest job, DashboardController controller) {
   final remainingRx = dashboardController.remainingTimeMap[job.projectId ?? 0];

final bool isExpired =
    remainingRx != null && remainingRx.value.inSeconds <= 0;


    return GestureDetector(
      
      onTap: () {

  if (isExpired) {
    Utils.showToast('This job is Expired');
  }

  else if (job.status == 'accepted') {
    Get.to(() => Work(
      projectId: job.projectId!.toString(),
      bookingNo: job.bookingNo!,
      acceptedAt: job.acceptedAt,
      onTabChange: widget.onTabChange,
    ));
  }

  else if (job.status == 'rejected') {
    Utils.showToast('This job is Rejected');
  }

  else {
    Utils.showToast("Accept the job first to start work");
  }

},
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
  
    final isPendingSync = dashboardController.pendingSyncBookings
        .contains(job.bookingNo ?? "");
    if (isPendingSync) return const SizedBox();

    final remaining = dashboardController
        .remainingTimeMap[job.projectId ?? 0]
        ?.value;

    if (remaining == null) return const SizedBox();

    if (remaining.inSeconds <= 0) {
      return GestureDetector(
        onTap: () => Utils.showToast("This job has expired."),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.timer_off, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text("Expired", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours   = twoDigits(remaining.inHours);
    final minutes = twoDigits(remaining.inMinutes.remainder(60));
    final seconds = twoDigits(remaining.inSeconds.remainder(60));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CustomColors.boxColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, size: 16, color: CustomColors.white),
          const SizedBox(width: 4),
          Text(
            "$hours:$minutes:$seconds",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
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
      ),
    );
  }

Widget _buildActionButtons(JobRequest job) {
  final status = (job.status ?? "").toLowerCase().trim();

  if (status == "rejected") {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: null,
        child: Utils.textView("Rejected", Get.width * 0.035, CustomColors.white, FontWeight.w700),
      ),
    );
  }

  if (status == "pending") {
    return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F3E8C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => dashboardController.updateJobStatus(
              job.projectId ?? 0, job.bookingNo ?? "", "accepted"),
          child: Utils.textView("Accept", Get.width * 0.035, CustomColors.white, FontWeight.w700),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.btnColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => dashboardController.updateJobStatus(
              job.projectId ?? 0, job.bookingNo ?? "", "rejected"),
          child: Utils.textView("Reject", Get.width * 0.035, CustomColors.white, FontWeight.w700),
        ),
      ),
    ],
  );

  } 



if (status == "accepted") {
  final remainingRx = dashboardController.remainingTimeMap[job.projectId ?? 0];

  final isPendingSync = dashboardController.pendingSyncBookings
      .contains(job.bookingNo ?? "");

  if (isPendingSync) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Utils.textView("Waiting for Sync", Get.width * 0.030, Colors.white, FontWeight.w700),
          ],
        ),
      ),
    );
  }

  if (remainingRx == null) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.btnColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.to(() => Work(
          projectId: job.projectId?.toString(),
          bookingNo: job.bookingNo ?? "",
          acceptedAt: job.acceptedAt,
          onTabChange: widget.onTabChange,
        )),
        child: Utils.textView("Inprogress", Get.width * 0.035, CustomColors.white, FontWeight.w700),
      ),
    );
  }

  return Obx(() {
    final isPendingSyncObs = dashboardController.pendingSyncBookings
        .contains(job.bookingNo ?? "");

    if (isPendingSyncObs) {
      return Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Utils.textView("Waiting for Sync", Get.width * 0.030, Colors.white, FontWeight.w700),
            ],
          ),
        ),
      );
    }

    final isExpired = remainingRx.value.inSeconds <= 0;
    if (isExpired) return const SizedBox();

   // return SizedBox(); 

    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.btnColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.to(() => Work(
          projectId: job.projectId?.toString(),
          bookingNo: job.bookingNo ?? "",
          acceptedAt: job.acceptedAt,
          onTabChange: widget.onTabChange,
        )),
        child: Utils.textView("Inprogress", Get.width * 0.035, CustomColors.white, FontWeight.w700),
      ),
    );
 
 
  });
}
  
 return SizedBox(); 


}


} 



/*
//in dashboard screen 
online - 1
offline -0
 if online then show projects which are come from customer app
 if offline then projects are not come 



 //usi ki job dikhe like job accept by other surveyor jo tha vha pr bs usi ki job dikhe if vo accept kr leta h otherwise vha show n ho 

 
*/