
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/workHistory_controller.dart';
import 'package:surveyor_app_planzaa/modal/wrokHistory_response_model.dart';
import 'package:surveyor_app_planzaa/pages/work.dart';


class WorkHistory extends StatefulWidget {
  const WorkHistory({super.key});

  @override
  State<WorkHistory> createState() => _WorkHistoryState();
}

class _WorkHistoryState extends State<WorkHistory> with SingleTickerProviderStateMixin {

 // final controller = Get.put(WorkHistoryController(Get.find<TickerProvider>()));

  late WorkHistoryController controller; 
  @override
  void initState() {
    super.initState();
    controller = Get.put(WorkHistoryController(this));
    controller.fetchWorkHistory();
  } 
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor:CustomColors.white,
      body: SafeArea(
        child: Column(
          children: [
          
            Expanded(
              child: Obx(() {
                
                if (controller.workList.isEmpty) { 
                  return  Center(
                    child: 
                     Utils.textView(
                          "Upload Images",
                          Get.width * 0.03,
                          Colors.grey,
                          FontWeight.w500,
                        ),
                
                  );
                }

                return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: controller.workList.length,
                    itemBuilder: (context, index) {
                      final work = controller.workList[index];
                      return _WorkCard(work: work);
                    },
                  );
                 
              }),
            ),
          ],
        ),
      ),

 
    
    );

  }
}


class _WorkCard extends StatelessWidget {
  final Works work;
  const _WorkCard({required this.work});

  @override
  Widget build(BuildContext context) {
    final int stars = (work.rating != null)
        ? (work.rating is int
            ? work.rating as int
            : (work.rating as double).round())
        : 0; 

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        Utils.textView(
                        'Job ID: ${work.bookingNo}', 
                          Get.width * 0.045,
                          Colors.black,
                          FontWeight.w600,
                        ),
       
           SizedBox(height: Get.height * 0.005),

         
          Text(
            work.completedAt != null
                ? _formatDate(work.completedAt!)
                : 'Completion date unknown',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

         
          Utils.textView(
                         '₹${work.amount?.toStringAsFixed(2) ?? '0.00'} Earned',
                          Get.width * 0.038,
                          Colors.black87,
                          FontWeight.w600,
                        ),
        
           SizedBox(height: Get.height * 0.001),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                           Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFC107),
                    size: 18,
                  );
                }),
              ),

               
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: 
                
                  Utils.textView(
                         'Completed',
                          Get.width * 0.03,
                          Color(0xFF4CAF50),
                          FontWeight.w600,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}