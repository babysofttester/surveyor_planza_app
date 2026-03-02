// Custom widget for date picker field
import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(selectedDate != null
          ? selectedDate!.toLocal().toString().split(' ')[0]
          : 'Select Date'),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () => _pickDate(context),
      ),
    );
  }
}
