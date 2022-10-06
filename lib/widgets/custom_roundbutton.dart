import 'package:flutter/material.dart';

class CustomRoundButton extends StatelessWidget {
  const CustomRoundButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.buttonColor,
    this.width = double.infinity,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.elevation,
    this.padding = const EdgeInsets.symmetric(vertical: 7.5),
  });

  final Function()? onPressed;
  final Widget? child;
  final Color? buttonColor;
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: buttonColor,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
        child: child,
      ),
    );
  }
}
