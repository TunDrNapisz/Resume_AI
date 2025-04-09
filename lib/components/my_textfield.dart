import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hindtext;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // Update the type of validator

  const MyTextField({
    Key? key,
    required this.hindtext,
    required this.obscureText,
    this.controller,
    this.validator, // Update the type here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: hindtext,
      ),
      obscureText: obscureText,
      validator: validator, // Add the validator here
    );
  }
}
