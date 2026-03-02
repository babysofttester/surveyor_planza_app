import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final String label;
  final Function(String) onChanged;

  const TextInputField(
      {super.key, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}
