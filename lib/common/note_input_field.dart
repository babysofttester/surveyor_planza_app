// Custom widget for multiline note input
import 'package:flutter/material.dart';

class NoteInputField extends StatelessWidget {
  final TextEditingController controller;

  const NoteInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Add a Note',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }
}
