import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  const CustomTextForm({
    super.key,
    this.hintText,
    this.fillColor = Colors.white,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.controller,
    this.prefixIcon,
    this.autofocus = false,
    this.borderWidth = 1.5,
    this.borderRadius = 12,
    this.borderColor = Colors.grey,
    this.borderFocusedColor = Colors.blue,
    this.borderErrorColor = Colors.red,
    this.searchColor = Colors.black,
    this.contentPadding = const EdgeInsets.all(20),
  });

  final String? hintText;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final bool autofocus;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final Color borderFocusedColor;
  final Color borderErrorColor;
  final Color searchColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: TextFormField(
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: fillColor,
          hintStyle: TextStyle(color: searchColor),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: borderFocusedColor, width: borderWidth),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderErrorColor, width: borderWidth),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderErrorColor, width: borderWidth),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          contentPadding: contentPadding,
          prefixIcon: prefixIcon,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        controller: controller,
        cursorColor: searchColor,
      ),
    );
  }
}
