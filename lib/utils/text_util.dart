// ignore_for_file: file_names

import 'package:flutter/material.dart';

Text txt(
  text, {
  isBold = false,
  double size = 13,
  String fontFamily = 'PlusJakartaSans', // Updated font to use custom font family
  TextDecoration decoration = TextDecoration.none,
  Color color = Colors.white,
  FontWeight weight = FontWeight.normal,
  int maxLine = 4,
  int minLine = 1,
  TextAlign textAlign = TextAlign.left,
  TextOverflow overflow = TextOverflow.ellipsis,
  double letterSpacing = 0.0,
}) {
  return Text(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLine,
    style: TextStyle(
      fontFamily: fontFamily,
      color: color,
      fontWeight: isBold ? FontWeight.bold : weight,
      fontSize: size,
      decoration: decoration,
      letterSpacing: letterSpacing,
    ),
  );
}