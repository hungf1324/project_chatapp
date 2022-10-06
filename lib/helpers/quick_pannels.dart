import 'package:flutter/material.dart';
import 'package:project_chatapp/helpers/quick_navigators.dart';
import '../widgets/quick_text.dart';

void showSnackBar(
  String message,
  BuildContext context, {
  double? size,
  Color? color,
  int duration = 2,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: qText(message, size: size),
    backgroundColor: color,
    duration: Duration(seconds: duration),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}

void showAlert({
  required BuildContext context,
  required String title,
  Widget? content,
  Function()? onAgreed,
  Function()? onRefused,
  Color? refuseColor,
  Color? agreeColor,
  String agreeText = 'Confirm',
  refuseText = 'Cancel',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: qText(title),
      content: content,
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: onRefused ?? () => goPop(context),
          child: qText(
            refuseText,
            size: 16,
            color: refuseColor,
          ),
        ),
        TextButton(
          onPressed: onAgreed,
          child: qText(
            agreeText,
            size: 16,
            color: agreeColor,
          ),
        ),
      ],
    ),
  );
}
