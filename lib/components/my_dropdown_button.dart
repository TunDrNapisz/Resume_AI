import 'package:flutter/material.dart';

class MyDropdownButtonForm extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const MyDropdownButtonForm({
    Key? key,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            hint: value == null ? Text(hintText) : null,
            decoration: const InputDecoration(
              border: InputBorder.none, // Hide the underline
            ),
            validator: validator,
            isExpanded: true,
            autofocus: true,
          ),
        ),
      ),
    );
  }
}
