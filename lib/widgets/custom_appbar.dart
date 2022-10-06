import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
CustomAppBar({
  Widget? title,
  Widget? leading,
  bool automaticallyImplyLeading = true,
  List<Widget>? actions,
  Color? backgroundColor = Colors.transparent,
  Color? foregroundColor = Colors.black,
}) {
  return AppBar(
    centerTitle: false,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: 0,
    leadingWidth: 25,
    title: title,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: actions,
  );
}
