import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_fonts.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).textTheme.bodyMedium?.color;

    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: AppFonts.poppinsFont,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: themeColor,
      ),
    );
  }
}
