import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/eraning_controller.dart';

class Earning extends StatefulWidget {
  const Earning({super.key});

  @override
  State<Earning> createState() => _EarningState(); 
}

class _EarningState extends State<Earning> with SingleTickerProviderStateMixin { 
  // late TabController _tabController;

 late EarningController controller;

@override
void initState() {
  super.initState();
  controller = Get.put(EarningController(this));
}
  @override
  Widget build(BuildContext context) { 
    

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: CustomColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
SizedBox(height: Get.height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: Get.height * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFF1A3A8F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Paid'),
                      Tab(text: 'Unpaid'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

           
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A3A8F)),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Utils.textViewAlign(
           controller.errorMessage.value,
          Get.height * 0.01,
          CustomColors.red,
          FontWeight.bold,
          TextAlign.center

        ),
                          
                           SizedBox(height: Get.height * 0.02),
                          ElevatedButton(
                            onPressed: controller.fetchEarnings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A8F),
                            ),
                            child:  Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    children: [
                    
                      _EarningsTab(
                        totalLabel: 'Total Earnings',
                        totalAmount: controller.totalEarnings.value,
                        items: controller.paidList
                            .map((p) => _EarningItem(
                                  bookingNo: p.bookingNo ?? '',
                                  date: p.paidAt ?? '',
                                  amount: p.amount ?? '₹0.00',
                                ))
                            .toList(),
                        onRefresh: controller.fetchEarnings,
                        emptyMessage: 'No paid earnings found.',
                      ),

                      
                      _EarningsTab(
                        totalLabel: 'Total Dues',
                        totalAmount: controller.totalDues.value,
                        items: controller.unpaidList
                            .map((u) => _EarningItem(
                                  bookingNo: u.bookingNo ?? '',
                                  date: '',
                                  amount: u.amount ?? '₹0.00',
                                ))
                            .toList(),
                        onRefresh: controller.fetchEarnings,
                        emptyMessage: 'No unpaid dues found.',
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),

        
       
      ),
    );
  }
}


class _EarningsTab extends StatelessWidget {
  final String totalLabel;
  final String totalAmount;
  final List<_EarningItem> items; 
  final Future<void> Function() onRefresh;
  final String emptyMessage;

  const _EarningsTab({
    required this.totalLabel,
    required this.totalAmount,
    required this.items,
    required this.onRefresh,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1A3A8F),
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
           color:   CustomColors.btnColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                child:
                  Utils.textView(
            '₹$totalAmount',
          Get.height * 0.03,
          CustomColors.boxColor,
          FontWeight.w700,
        ), 
               
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: 
                Utils.textView(
              totalLabel,
          Get.height * 0.017,
          Colors.grey,
          FontWeight.w500,
        ), 
              ),
SizedBox(height: Get.height * 0.01),
             
              const Divider(height: 12, thickness: 1, color: Color(0xFFEEEEEE)),

              
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: 

                      Utils.textView(
              emptyMessage,
          Get.height * 0.017,
          Colors.grey,
          FontWeight.w500, 
        ), 
                   
                  ),
                )
              else
                ...items.map((item) => _EarningRow(item: item)).toList(),

               SizedBox(height: Get.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}


class _EarningRow extends StatelessWidget {
  final _EarningItem item;
  const _EarningRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Utils.textView(
              'Job ID: ${item.bookingNo}',
          Get.height * 0.02,
          Colors.black87,
          FontWeight.w700,  
        ), 
        
                  if (item.date.isNotEmpty) ...[
                    const SizedBox(height: 3),
                     Utils.textViewStyle(
              _formatDate(item.date),
          Get.height * 0.016,
          Colors.grey,
          FontWeight.w400,  
        ), 
                   
                  ],
                ],
              ),

              

                 Utils.textView(
             item.amount.startsWith('₹')
                    ? item.amount
                    : '₹${item.amount}',
          Get.height * 0.02,
          Colors.black87,
          FontWeight.w700,  
        ), 
             
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        '',
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr; 
    }
  }
}


class _EarningItem {
  final String bookingNo;
  final String date;
  final String amount;

  const _EarningItem({
    required this.bookingNo,
    required this.date,
    required this.amount,
  });
}