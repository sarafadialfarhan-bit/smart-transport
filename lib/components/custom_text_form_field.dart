import 'package:flutter/material.dart';
import '../constants.dart';

class CustomTextFormField extends StatelessWidget {
  final String title;
  final bool isPassword;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const CustomTextFormField({
    super.key,
    required this.title,
    this.isPassword = false,
    this.icon,
    this.validator,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: title,
        prefixIcon: icon != null ? Icon(icon, color: kPrimaryColor) : null,
        labelStyle: const TextStyle(color: kPrimaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
