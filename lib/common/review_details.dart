import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewDetails extends StatelessWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final String? guestName;
  final XFile? image;
  final String note;

  const ReviewDetails({
    super.key,
    this.checkInDate,
    this.checkOutDate,
    this.guestName,
    this.image,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Check-in Date: ${checkInDate ?? 'Not selected'}'),
        Text('Check-out Date: ${checkOutDate ?? 'Not selected'}'),
        Text('Guest Name: ${guestName ?? 'Not provided'}'),
        Text('Note: ${note.isNotEmpty ? note : 'No note added'}'),
        if (image != null) Image.network(image!.path),
      ],
    );
  }
}
