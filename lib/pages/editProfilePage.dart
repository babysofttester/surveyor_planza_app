import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surveyor_app_planzaa/common/appBar.dart';
import 'package:surveyor_app_planzaa/common/custom_colors.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/controller/profileController.dart';
import 'package:surveyor_app_planzaa/controller/state_citiy_controller.dart';
import 'package:surveyor_app_planzaa/custom_widgets/map_picker.dart';
import 'package:surveyor_app_planzaa/custom_widgets/searchabledropdown.dart';
import 'package:surveyor_app_planzaa/pages/home.dart';
import 'package:timezone/timezone.dart' hide Location;
import 'package:geocoding/geocoding.dart';



class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  late ProfileController profileController;
  late StateCityController stateCityController; 
  


@override
void initState() {
  super.initState();
  try {
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(this));

    stateCityController = Get.isRegistered<StateCityController>()
        ? Get.find<StateCityController>()
        : Get.put(StateCityController());

    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();

    stateCityController.fetchStates();
    _fillFields();
    profileController.addListener(_fillFields);
    
  } catch (e, stack) {
    print("INIT ERROR: $e");
    print("STACK: $stack");
  }
}

void _fillFields() {
  final surveyor = profileController.surveyor;
  if (surveyor == null) return;
  
  nameController.text = surveyor.name ?? '';
  phoneController.text = surveyor.phone ?? '';
  emailController.text = surveyor.email ?? '';

  if (surveyor.state != null && surveyor.state!.isNotEmpty) {
    stateCityController.selectedState.value = surveyor.state;
    

    stateCityController.fetchCities(surveyor.state!).then((_) {
      if (surveyor.city != null && surveyor.city!.isNotEmpty) {
        if (stateCityController.cities.contains(surveyor.city)) {
          stateCityController.selectedCity.value = surveyor.city; 
        }
      }
    });
  }
}

@override
void dispose() {
  profileController.removeListener(_fillFields); 
  nameController.dispose();
  phoneController.dispose();
  emailController.dispose();
  super.dispose();
}

  // @override
  // void dispose() {
  //   nameController.dispose();
  //   phoneController.dispose();
  //   emailController.dispose();
  //   super.dispose();
  // }

  File? profileImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
      });

      profileController.profileImageFile = profileImageFile;
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

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    try{
 return Scaffold(
      backgroundColor: Colors.white,

      appBar: const CustomAppBar(title: "Edit Profile"),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageFile != null
                            ? FileImage(profileImageFile!)
                            : profileController.surveyor?.avatar != null &&
                                  profileController.surveyor!.avatar!.isNotEmpty
                            ? NetworkImage(profileController.surveyor!.avatar!)
                            : const AssetImage("assets/images/profile.png")
                                  as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: GestureDetector(
                        onTap: showImagePickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: CustomColors.darkblue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.02),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Utils.textView(
                    "Name",
                    Get.width * 0.04,
                    CustomColors.black,
                    FontWeight.w500,
                  ),

                  //  SizedBox(height: Get.height * 0.01),
                  _textField(
                    icon: Icons.person,
                    hint: "Enter your name",
                    controller: nameController,
                    readOnly: false,
                  ),
                  SizedBox(height: Get.height * 0.02),

                  /// STATE
                  Row(
  children: [

    /// STATE
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 18,
            child: Utils.textView(
              "State",
              Get.width * 0.04,
              CustomColors.black,
              FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Obx(
            () => SearchableDropdown(
              hint: "Select State",
              items: stateCityController.states,
              value: stateCityController.selectedState.value,
              onSelected: (val) {
                stateCityController.selectedState.value = val;
                stateCityController.fetchCities(val);
              },
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 12),

    /// DISTRICT
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 18,
            child: Utils.textView(
              "District",
              Get.width * 0.04,
              CustomColors.black,
              FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Obx(
            () => SearchableDropdown(
              hint: "Select District", 
              items: stateCityController.cities,
              value: stateCityController.selectedCity.value,
              onSelected: (val) {
                stateCityController.selectedCity.value = val;
              },
            ),
          ),
        ],
      ),
    ),
 
 
  ],
), 
     SizedBox(height: Get.height * 0.02),
                  // const SizedBox(height: 12),

 //lat long
                //lat long
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (stateCityController.selectedState.value == null ||
                                  stateCityController.selectedCity.value == null) {
                                Get.snackbar(
                                  "Error",
                                  "Please select state and district first",
                                );
                                return;
                              }

                              String address =
                                  "${stateCityController.selectedCity.value}, ${stateCityController.selectedState.value}, India";

                              List<Location> locations =
                                  await locationFromAddress(address);

                              if (locations.isEmpty) {
                                Get.snackbar( 
                                  "Error",
                                  "Unable to find district location",
                                );
                                return;
                              }

                              LatLng districtLatLng = LatLng(
                                locations.first.latitude,
                                locations.first.longitude,
                              );

                              final LatLng? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapPickerPage(
                                    initialLocation: districtLatLng,
                                  ),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  latitudeController.text =
                                      result.latitude.toString();
                                  longitudeController.text =
                                      result.longitude.toString();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F3C88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_location_alt_sharp,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: Get.width * 0.02),
                                Utils.textView(
                                  "Select Location",
                                  Get.height * 0.02,
                                  CustomColors.white,
                                  FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.01),
                        Row(
                          children: [
                            // Icon(Icons.share_location_rounded),
                            // const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.textView(
                                    "Latitude",
                                    Get.width * 0.038,
                                    CustomColors.black,
                                    FontWeight.w500,
                                  ),
                                  // Text(
                                  //   "Latitude",
                                  //   // style: AppFonts.arcPop1()
                                  // ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () {},
                                    child: _textField(
                                      hint: "Latitude",
                                      controller: latitudeController, icon: Icons.location_pin,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.textView(
                                    "Longitude",
                                    Get.width * 0.038,
                                    CustomColors.black,
                                    FontWeight.w500,
                                  ),
                                  // Text(
                                  //   "Longitude",
                                  //   // style: AppFonts.arcPop1()
                                  // ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () {},
                                    child: _textField(
                                      hint: "Longitude",
                                      controller: longitudeController, icon: Icons.location_pin,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    SizedBox(height: Get.height * 0.02),
                 
                  Utils.textView(
                    "Phone",
                    Get.width * 0.04,
                    CustomColors.black,
                    FontWeight.w500,
                  ),

                
                  _textField(
                    icon: Icons.phone,
                    hint: "Enter phone number",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    readOnly: true,
                  ),

                  SizedBox(height: Get.height * 0.02),

                  Utils.textView(
                    "Email",
                    Get.width * 0.04,
                    CustomColors.black,
                    FontWeight.w500,
                  ),

                  _textField(
                    icon: Icons.email,
                    hint: "Enter email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: false,
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.03),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                onPressed: () { 
  final profileController = Get.find<ProfileController>();
  final stateCityController = Get.find<StateCityController>(); 

 
  profileController.selectedState.value = stateCityController.selectedState.value;
  profileController.selectedCity.value = stateCityController.selectedCity.value;

  profileController.updateProfile(
    name: nameController.text.trim(),
    email: emailController.text.trim(),
    image: profileImageFile,
  );
},
                  child: Utils.textView(
                    "Save",

                    Get.height * 0.02,
                    CustomColors.white,
                    FontWeight.bold,
                  ),
                 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  
    }catch (e, stack) {
    print("BUILD ERROR: $e");
    print("STACK: $stack");
    return Scaffold(
      body: Center(child: Text("Error: $e")),
    );
  }
   
  }

  Widget _textField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          // hintStyle: AppFonts.arcPop1(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1F3C88)),
          ),
        ),
        cursorColor: const Color(0xFF1F3C88),
      ),
    );
  }
  
}
  Widget _textField1({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
     hintStyle: TextStyle(
  color: CustomColors.textGrey,
  fontSize: 15
),


        // hintStyle: AppFonts.arcPop1(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F3C88)),
        ),
      ),
      cursorColor: Color(0xFF1F3C88),
    );
  }
