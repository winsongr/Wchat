import 'package:chatapp/constants/texttheme.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    Key? key,
    required this.txtstyle,
    required this.text, this.overflow,
  }) : super(key: key);

  final TextStyle txtstyle;
  final String text;
  final overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textScaleFactor: TextThemes.textscale,
      style: txtstyle,
      overflow: overflow,
    );
  }
}
