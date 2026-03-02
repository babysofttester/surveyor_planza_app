import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/appBar.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/dashboard_controller.dart';
import 'package:surveyor_app_planzaa/controller/work_controller.dart';

class Work extends StatefulWidget {
  final String? projectId;
  final String? bookingNo;
  final String? acceptedAt;


  const Work({super.key,  this.projectId,  this.bookingNo, this.acceptedAt}); 

  @override
  State<Work> createState() => _WorkState();
}

class _WorkState extends State<Work> with SingleTickerProviderStateMixin {
 late WorkController workController;
 late DashboardController dashboardController;

 @override
void initState() {
  super.initState();


 dashboardController = Get.put(DashboardController(this)); 
  workController = Get.put(WorkController(this));

  if (widget.projectId != null) {
    workController.projectId = widget.projectId!;
  }

  if (widget.bookingNo != null) {
    workController.bookingNo = widget.bookingNo!;
  }

}

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: CustomColors.white,
      appBar: CustomAppBar(title: "Work"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GetBuilder<WorkController>(
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job ID + Timer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Utils.textView(
                              "Job ID: ${widget.bookingNo ?? ''}",
                              Get.width * 0.045,
                              CustomColors.black,
                              FontWeight.w700,
                            ),

                          Obx(() {
  final remaining = dashboardController
      .remainingTimeMap[int.tryParse(widget.projectId ?? "") ?? 0]
      ?.value;

  if (remaining == null) {
    return const SizedBox();
  }

  if (remaining.inSeconds <= 0) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Expired",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final hours = twoDigits(remaining.inHours);
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
})
                          ],
                        ),

                        const SizedBox(height: 20),

                       
                        Utils.textView(
                          "Upload Images",
                          Get.width * 0.045,
                          CustomColors.black,
                          FontWeight.w700,
                        ),

                        const SizedBox(height: 12),

                      
                        Obx(() => controller.selectedImages.isEmpty
                            ? _addPhotoBox(controller)
                            : Column(
                                children: [
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount:
                                        controller.selectedImages.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          controller.selectedImages.length) {
                                       
                                        return GestureDetector(
                                          onTap: controller.pickImages,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.grey),
                                          ),
                                        );
                                      }
                                      return Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              File(controller
                                                  .selectedImages[index].path),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  controller.removeImage(index),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: CustomColors.boxColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close,
                                                    size: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              )),

                        const SizedBox(height: 20),

                        // Length
                        _label("Length"),
                        _inputField(
                          controller: controller.lengthController,
                          hint: "0.00",
                          suffix: "Meters",
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 14),

                        // Breadth
                        _label("Breadth"),
                        _inputField(
                          controller: controller.breadthController,
                          hint: "0.00",
                          suffix: "Meters",
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 14),

                        // Description
                        _label("Description"),
                        TextField(
                          controller: controller.descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Description",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Complete Button
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.submitWork,
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Utils.textView(
                                        "Complete",
                                        Get.width * 0.045,
                                        Colors.white,
                                        FontWeight.w700,
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _addPhotoBox(WorkController controller) {
    return GestureDetector(
      onTap: controller.pickImages,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Icon(Icons.add, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text("Add Photo",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text("Upload relevant work images",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Utils.textView(
          text, Get.width * 0.035, CustomColors.black, FontWeight.w500),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixText: suffix,
        suffixStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}