import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surveyor_app_planzaa/common/assets.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/pages/earning.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';
import 'package:surveyor_app_planzaa/pages/supportScreen.dart';

import '../controller/profileController.dart';
import 'editProfilePage.dart';

class ProfileScreen extends StatefulWidget {
   final Function(int)? onTabChange;


  const ProfileScreen({super.key,  this.onTabChange});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
   with TickerProviderStateMixin {
  late final ProfileController controller; 
  final ImagePicker _picker = ImagePicker();

@override
void initState() {
  super.initState();
 
  if (Get.isRegistered<ProfileController>()) {
    Get.delete<ProfileController>(force: true); 
  }
  controller = Get.put(ProfileController(this));
}

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      // controller.profileImageFile = File(pickedFile.path);
      controller.update(); // refresh UI
    }
  }

  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              const Text(
                "Choose Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
        
                GetBuilder<ProfileController>(
                  builder: (controller) {
                    ImageProvider imageProvider;

                 
      
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const EditProfilePage(),
                          transition: Transition.fade,
                          duration: const Duration(milliseconds: 400),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
  height: 80,
  width: 80,
  child: Stack(
    children: [
      CircleAvatar(
  radius: 40,
  backgroundColor: Colors.grey.shade200,
  backgroundImage: controller.surveyor?.avatar != null &&
          controller.surveyor!.avatar!.isNotEmpty
      ? NetworkImage(controller.surveyor!.avatar!)
      : null,
  child: controller.surveyor?.avatar == null ||
          controller.surveyor!.avatar!.isEmpty
      ? Image.asset(
          Assets.profilePNG,
          fit: BoxFit.cover,
        ) 
      : null,
),

      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: showImagePickerOptions,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(
              Icons.edit,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  ),
),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                               controller.surveyor?.name ?? "No Name",
                                //controller.customer?.name ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text( 
                                controller.surveyor?.email ?? "No Email",
                               // controller.customer?.email ?? "",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

            
                _menuItem(Icons.home_outlined, "Dashboard", () {
                   widget.onTabChange?.call(0); 
                
                }),

           

                _menuItem(Icons.card_travel, "Work History", () {
                      widget.onTabChange?.call(1); 
                 
                }),

                _menuItem(Icons.payment, "Earning", () {
                  widget.onTabChange?.call(2); 
                }), 

                // _menuItem(Icons.lock_outline_rounded, "Forgot Password", () {
                //   Get.to(() => const SupportScreen());
                // }),

                _menuItem(Icons.email_outlined, "Support", () {
                  Get.to(() => const SupportScreen());
                }),

                _menuItem(Icons.privacy_tip_outlined, "Privacy Policy", () {
                  Get.to(() => const SupportScreen());
                }),

                _menuItem(Icons.logout, "Logout", () {
                  Get.offAll(() => const LoginPage()); 
                }), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color:CustomColors.black ),
          title: 
             Utils.textView(
                                title,
                                Get.width * 0.042,
                                CustomColors.black,
                                FontWeight.normal,
                              ),
         // Text(title),
         // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          thickness: 0.8,
          color: CustomColors.outlineGrey,  
        ),
      ],
    );
  }
}
