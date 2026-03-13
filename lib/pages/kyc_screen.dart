import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveyor_app_planzaa/common/appBar.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/custom_widgets/searchabledropdown.dart';
import '../controller/kyc_controller.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState(); 
}

class _KycScreenState extends State<KycScreen>with SingleTickerProviderStateMixin {
    late KycController kycController;
  @override
  void initState() {
    super.initState();
    kycController = Get.put(KycController(this));
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold( 
        backgroundColor: Colors.white,
        appBar:  CustomAppBar(title:  "KYC "),
        body: 
            SingleChildScrollView( 
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
          
               Obx(() {
  if (!kycController.isRejected.value) {
    return const SizedBox();
  }

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.red.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Utils.textView(
          "Your KYC has been rejected",
          Get.width * 0.04,
          Colors.red,
          FontWeight.bold,
        ),

        const SizedBox(height: 6),

        Utils.textView(
          "Reason: ${kycController.rejectReason.value}",
          Get.width * 0.033,
          Colors.black,
          FontWeight.normal,
        ),

        const SizedBox(height: 6),

        Utils.textView(
          "Please submit a valid document and try again.",
          Get.width * 0.032,
          Colors.black54,
          FontWeight.normal,
        ),
      ],
    ),
  );
}),
                      Utils.textView(
                      "Complete Your KYC",
                      Get.width * 0.05,
                      CustomColors.black,
                      FontWeight.bold,
                    ),
          
                 SizedBox(height: Get.height * 0.01),
                       Utils.textViewAlign(
                      "Submit your documents for a secure verification process.",
                      Get.width * 0.03,
                      CustomColors.hintColor,
                      FontWeight.normal,
                      TextAlign.center,
                    ),
          
                SizedBox(height: Get.height * 0.02),
          
      
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // SizedBox(height: Get.height * 0.01),
                      Utils.textView(
                      "Photo Identity",
                      Get.width * 0.038,
                      CustomColors.black,
                      FontWeight.w500, 
                    ),
              // Text("Photo Identity"),
              
      Obx(() => SearchableDropdown(
        hint: "Select Photo Identity",
        items: kycController.photoIdentityList,
        value: kycController.selectedPhotoIdentity.value,
        onSelected: (val) {
      kycController.selectedPhotoIdentity.value = val;
        },
      )),
               
                 SizedBox(height: Get.height * 0.01),
          
          //button
                SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
      onPressed: () => kycController.pickFile("photo"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: CustomColors.boxColor, 
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      icon: const Icon(Icons.cloud_upload_outlined),
      label: const Text("Upload Photo Identity"),
        ),
      ),
      //show file name
          Obx(() {
        if (kycController.photoFile.value == null) {
      return const SizedBox();
        }
        return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kycController.photoFile.value!.path.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
        ),
      ),
        );
      }),
                
                
                
                 SizedBox(height: Get.height * 0.02),
          
                Utils.textView(
                      "Address Proof",
                      Get.width * 0.038,
                      CustomColors.black,
                      FontWeight.w500,
                    ),
             
      
      Obx(() => SearchableDropdown(
        hint: "Select Address Proof",
        items: kycController.addressProofList,
        value: kycController.selectedAddressProof.value,
        onSelected: (val) {
      kycController.selectedAddressProof.value = val;
        },
      )),
          
                SizedBox(height: Get.height * 0.01),
                 SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
      onPressed: () => kycController.pickFile("address"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: CustomColors.boxColor, 
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      icon: const Icon(Icons.cloud_upload_outlined),
      label: const Text("Upload Address Proof"),
        ),
      ),
                  Obx(() {
        if (kycController.addressFile.value == null) {
      return const SizedBox();
        }
        return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kycController.addressFile.value!.path.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
        ),
      ),
        );
      }),
                
             
                
          
                SizedBox(height: Get.height * 0.02),
                   Utils.textView(
                      "Highest Education",
                      Get.width * 0.038, 
                      CustomColors.black,
                      FontWeight.w500,
                    ),
          
              
      
      Obx(() => SearchableDropdown(
        hint: "Select Highest Education",
        items: kycController.educationList,
        value: kycController.selectedEducation.value,
        onSelected: (val) {
      kycController.selectedEducation.value = val;
        },
      )), 
          
                 SizedBox(height: Get.height * 0.01),
                     SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
      onPressed: () => kycController.pickFile("education"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: CustomColors.boxColor, 
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      icon: const Icon(Icons.cloud_upload_outlined),
      label: const Text("Upload Education Proof"),
        ),
      ),
          
                                Obx(() {
        if (kycController.educationFile.value == null) {
       return const SizedBox();
        }
        return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kycController.educationFile.value!.path.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
        ),
      ),
        );
      }),
          
               SizedBox(height: Get.height * 0.02),
      
      
          
               Obx(() => kycController.isLoading.value
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : SizedBox(
          width: double.infinity,
          height: Get.height * 0.06,
          child: ElevatedButton(
            onPressed: kycController.submitKyc,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.boxColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Utils.textView(
              "Submit",
              Get.height * 0.02,
              CustomColors.white, 
              FontWeight.bold,
            ),
          ),
        ),
      )
            ],
          ),
      
              ],
            ),
            ),
          
        
        
      
       
      ),
    );
  }   
} 