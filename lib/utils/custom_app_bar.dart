// Custom AppBar Component
import 'package:flutter/material.dart';
import 'package:hacknow/utils/text_util.dart';

PreferredSizeWidget customAppBar({
  required String title,
  List<Widget>? actions,
  Widget? leading,
  Color backgroundColor = const Color(0xFF1A1A24),
  Color titleColor = Colors.white,
  double elevation = 4.0,
  bool centerTitle = false,
  double textSize = 20,
}) {
  return AppBar(
    title: txt(
      title,
      isBold: true,
      size: textSize,
      color: titleColor,
    ),
    automaticallyImplyLeading: leading != null ? true : false,
    backgroundColor: backgroundColor,
    elevation: elevation,
    centerTitle: centerTitle,
    actions: actions,
    leading: leading,
  );
}