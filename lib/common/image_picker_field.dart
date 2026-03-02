// Custom widget for image picker field
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatelessWidget {
  final XFile? image;
  final Function(XFile) onImageSelected;
  final ImagePicker _picker = ImagePicker();

  ImagePickerField(
      {super.key, required this.image, required this.onImageSelected});

  Future<void> _showImagePicker(BuildContext context) async {
    final XFile? pickedFile = await showDialog<XFile>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        title: const Text('Select Image'),
        actions: [
          TextButton(
            onPressed: () async {
              final XFile? file =
                  await _picker.pickImage(source: ImageSource.camera);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(file);
            },
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () async {
              // Pick from gallery using FilePicker
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(
                result != null && result.files.single.path != null
                    ? File(result.files.single.path!)
                    : null,
              );
            },
            // onPressed: () async {
            //   final XFile? file =
            //       await _picker.pickImage(source: ImageSource.gallery);
            //   // ignore: use_build_context_synchronously
            //   Navigator.of(context).pop(file);
            // },
            child: const Text("Gallery"),
          ),
        ],
      ),
    );

    if (pickedFile != null) onImageSelected(pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Upload Photo'),
      subtitle:
          image != null ? Text(image!.name) : const Text('No image selected'),
      trailing: IconButton(
        icon: const Icon(Icons.photo),
        onPressed: () => _showImagePicker(context),
      ),
    );
  }
}
