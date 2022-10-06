import 'package:flutter/material.dart';

goNextScreen(BuildContext context, {required Widget screen}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

goReplaceScreen(BuildContext context, {required Widget screen}) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
}

goRemoveUntilScreen(
  BuildContext context, {
  required Widget screen,
  bool predicate = false,
}) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (route) => predicate,
  );
}

goPop(BuildContext context) => Navigator.pop(context);
