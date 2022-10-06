import 'package:flutter/material.dart';

// ignore: camel_case_types
class qText extends StatelessWidget {
  const qText(
    this.text, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.style,
    this.overflow,
    this.align = TextAlign.center,
  });

  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final FontStyle? style;
  final TextOverflow? overflow;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        fontStyle: style,
      ),
      overflow: overflow,
      textAlign: align,
    );
  }
}
