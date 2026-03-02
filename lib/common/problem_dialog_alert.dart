// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' as g;
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:dio/dio.dart';
// import 'package:miracle_manager/common/api_urls.dart';
// import 'package:miracle_manager/common/custom_colors.dart';
// import 'package:miracle_manager/common/translation_singleton.dart';
// import 'package:miracle_manager/common/utils.dart';
// import 'package:miracle_manager/pages/pool_page.dart';

// class PoolProblemDialog extends StatefulWidget {
//   final String poolId;
//   final String latitude;
//   final String longitude;
//   final String authToken;
//   final String villaId;
//   final String userLat,

//   const PoolProblemDialog({
//     super.key,
//     required this.poolId,
//     required this.latitude,
//     required this.longitude,
//     required this.authToken,
//     required this.villaId,
//   });

//   @override
//   State<PoolProblemDialog> createState() => _PoolProblemDialogState();
// }

// class _PoolProblemDialogState extends State<PoolProblemDialog> {
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _commentController = TextEditingController();
//   final List<File> _images = [];

//   ///  Pick image source — camera or gallery
//   Future<void> _showImageSourcePicker() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final XFile? photo =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (photo != null) {
//                     setState(() => _images.add(File(photo.path)));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final result = await FilePicker.platform
//                       .pickFiles(allowMultiple: true, type: FileType.image);
//                   if (result != null && result.files.isNotEmpty) {
//                     setState(() {
//                       _images.addAll(result.files
//                           .where((file) => file.path != null)
//                           .map((file) => File(file.path!)));
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// 🔽 Compress images before upload
//   Future<File> _compressImage(File file) async {
//     final targetPath =
//         '${file.parent.path}/compressed_${file.uri.pathSegments.last}';
//     final XFile? result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 90,
//     );
//     return result != null ? File(result.path) : file;
//   }

//   /// 📤 Submit data to API with detailed logging + Authorization header
//   Future<void> _submit() async {
//     if (_images.isEmpty) {
//       Utils.showToast(
//         TranslationService()
//             .getTranslation('please_upload_image_before_continuing_text'),
//       );
//       return;
//     }

//     const String apiUrl = ApiUrls.poolProblem;

//     try {
//       Utils.print('============================');
//       Utils.print('Submitting Pool Problem Data');
//       Utils.print('URL: $apiUrl');
//       Utils.print('============================');
//       var authToken = widget.authToken;

//       Utils.print(
//           ' Token: ${authToken.isNotEmpty ? 'Token Found ' : 'No Token '}');

//       // Compress all images
//       List<File> compressedImages = [];
//       for (var img in _images) {
//         File compressed = await _compressImage(img);
//         compressedImages.add(compressed);
//       }

//       // Build form data
//       FormData formData = FormData.fromMap({
//         'pool_id': widget.poolId,
//         'latitude': widget.latitude,
//         'longitude': widget.longitude,
//         'end_time': DateTime.now().toIso8601String(),
//         'comment': _commentController.text,
//            "latitude": userLat.value.toString(),
//       "longitude": userLng.value.toString(),
//         ...
//         for (int i = 0; i < compressedImages.length; i++)
//           'image[$i]': await MultipartFile.fromFile(
//             compressedImages[i].path,
//             filename: 'image_$i.jpg',
//           ),
//       });

//       // Prepare Dio instance
//       final Dio dio = Dio()
//         ..options.headers = {
//           'Content-Type': 'multipart/form-data',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         };

//       //  Log request headers
//       Utils.print('📤 Request Headers:');
//       dio.options.headers.forEach((k, v) {
//         Utils.print('   $k: $v');
//       });

//       //  Log form data fields (without large files)
//       Utils.print('  Form Data Fields:');
//       for (var field in formData.fields) {
//         final key = field.key;
//         final value = field.value.length > 100
//             ? '${field.value.substring(0, 100)}...'
//             : field.value;
//         Utils.print('   $key: $value');
//       }
//       Utils.print(' Images Attached: ${compressedImages.length}');

//       //  API call
//       var response = await dio.post(apiUrl, data: formData);

//       //  Log response
//       Utils.print('============================');
//       Utils.print(' Response Status: ${response.statusCode}');
//       Utils.print(' Response Data: ${response.data}');
//       Utils.print('============================');

//       if (response.statusCode == 200) {
//         // ignore: use_build_context_synchronously
//         Navigator.pop(context);
//         // Utils.showToast('Problem details submitted successfully');
//         g.Get.to(() => PoolScreen(
//               selectedPropertyID: widget.villaId,
//             ));
//       } else {
//         Utils.print(' Failed: ${response.statusMessage}');
//         Utils.showToast('Failed: ${response.statusMessage}');
//       }
//     } catch (e) {
//       Utils.print(' Error submitting data: $e');
//       Utils.showToast('Error submitting data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     log("poolid :: ${widget.poolId}");
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: AlertDialog(
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(30),
//               bottomLeft: Radius.circular(30),
//             ),
//           ),
//           backgroundColor: Colors.white,
//           insetPadding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           contentPadding: const EdgeInsets.all(16),
//           scrollable: true,
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   height: g.Get.height * 0.02,
//                 ),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     for (var img in _images)
//                       Stack(
//                         children: [
//                           Image.file(img,
//                               width: 80, height: 80, fit: BoxFit.cover),
//                           Positioned(
//                             right: 0,
//                             top: 0,
//                             child: GestureDetector(
//                               onTap: () => setState(() => _images.remove(img)),
//                               child: const CircleAvatar(
//                                 radius: 10,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.close,
//                                     size: 14, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     IconButton(
//                       icon: const Icon(Icons.add_a_photo, color: Colors.blue),
//                       onPressed: _showImageSourcePicker,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _commentController,
//                   maxLines: 2,
//                   maxLength: 100,
//                   style: const TextStyle(color: Colors.black),
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: const TextStyle(color: Colors.grey),
//                     filled: true,
//                     fillColor: Colors.grey[200], // Always grey background
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           actions: [
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Center(
//                   child: ElevatedButton.icon(
//                       onPressed: () {
//                         if (FocusManager.instance.primaryFocus != null &&
//                             FocusManager.instance.primaryFocus!.hasFocus) {
//                           FocusManager.instance.primaryFocus?.unfocus();
//                         }
//                         Navigator.of(context).pop();
//                       },
//                       icon: Icon(
//                         Icons.cancel_outlined,
//                         size: g.Get.width * 0.05,
//                       ),
//                       label: Text(
//                         TranslationService().getTranslation('cancel_text'),
//                         style: TextStyle(fontSize: g.Get.width * 0.03),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: CustomColors.darkred,
//                           foregroundColor: CustomColors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50))))),
//               SizedBox(width: g.Get.width * 0.04),
//               Center(
//                   child: ElevatedButton.icon(
//                       onPressed: () {
//                         _submit();
//                       },
//                       icon:
//                           Icon(Icons.thumb_up_sharp, size: g.Get.width * 0.05),
//                       label: Text(
//                           TranslationService().getTranslation('confirm_text'),
//                           style: TextStyle(fontSize: g.Get.width * 0.03)),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: CustomColors.green,
//                           foregroundColor: CustomColors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50)))))
//             ])
//           ]),
//     );
//   }
// }
