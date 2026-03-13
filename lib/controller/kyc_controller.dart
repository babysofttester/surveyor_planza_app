import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyor_app_planzaa/common/utils.dart';
import 'package:surveyor_app_planzaa/core/api/api_endpoint.dart';
import 'package:surveyor_app_planzaa/modal/kyc_response_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:surveyor_app_planzaa/common/web_service.dart';
import 'package:surveyor_app_planzaa/pages/home.dart';
import 'package:surveyor_app_planzaa/pages/login_page.dart';


class KycController extends GetxController {
   final TickerProvider _tickerProvider;
    KycController(this._tickerProvider);

  //final Dio _dio = Dio();

 
  final List<String> photoIdentityList = [
    "Aadhar Card",
    "PAN Card",
    "Voter ID",
    "Driver’s Licence"
  ]; 

 var selectedPhotoIdentity = RxnString();

  
  final List<String> addressProofList = [
    "Aadhar Card",
    "Voter ID Card",
    "Other"
  ];

 var selectedAddressProof = RxnString();

 
  final List<String> educationList = [
    "Engineering",
    "Diploma"
  ];

var selectedEducation = RxnString();

  
var photoFile = Rxn<File>();
var addressFile = Rxn<File>();
var educationFile = Rxn<File>();

  var isLoading = false.obs;
RxBool isRejected = false.obs;
RxString rejectReason = "".obs;

 
Future<void> pickFile(String type) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.any);

  if (result != null && result.files.single.path != null) {
    File file = File(result.files.single.path!);

    if (type == "photo") {
      photoFile.value = file;
    } else if (type == "address") {
      addressFile.value = file;
    } else {
      educationFile.value = file;
    }
  }
}

 
Future<void> submitKyc() async {
  if (selectedPhotoIdentity.value == null ||
      selectedAddressProof.value == null ||
      selectedEducation.value == null ||
      photoFile.value == null ||
      addressFile.value == null ||
      educationFile.value == null) {
    Utils.showToast("Please complete all fields");
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("auth_token") ?? "";

  Map<String, String> data = {
    "photo_identity": selectedPhotoIdentity.value ?? "",
    "address_proof": selectedAddressProof.value ?? "",
    "educational_proof": selectedEducation.value ?? "",
  };

  List<http.MultipartFile> files = [
    await http.MultipartFile.fromPath(
      "photo_identity_file",
      photoFile.value!.path,
    ),
    await http.MultipartFile.fromPath(
      "address_proof_file",
      addressFile.value!.path,
    ),
    await http.MultipartFile.fromPath(
      "educational_proof_file",
      educationFile.value!.path,
    ),
  ];

  callMultipartWebApi(
    _tickerProvider,
    ApiEndpoints.kycSubmit,
    data,
    files,
    token: token,
  onResponse: (response) async {
  KycResponseModel model =
      KycResponseModel.fromJson(response);

  if (model.status == "success") {

    Utils.showToast(model.message ?? "KYC Submitted");
    Get.offAll(() => LoginPage());  

  } else {
    Utils.showToast(model.message ?? "KYC Failed");
  }
},
  );
}

} 