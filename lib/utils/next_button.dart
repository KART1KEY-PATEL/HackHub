import 'package:flutter/material.dart';
import 'package:hacknow/utils/text_util.dart';

class NextButton extends StatelessWidget {
  NextButton({
    super.key,
    this.lastPage = false,
    this.navigateTo = "",
    required this.title,
    required this.onTapFunction,
  });
  final String navigateTo;
  final String title;
  final bool lastPage;
  VoidCallback onTapFunction;

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        onTapFunction();
        if (navigateTo != "") {
          navigateTo.length != 0
              ? lastPage
                  ? Navigator.of(context).pushNamedAndRemoveUntil(
                      navigateTo, (Route<dynamic> route) => false)
                  : Navigator.pushNamed(context, navigateTo)
              : print("No route specified");
        }
      },
      child: Container(
        height: sH * 0.07,
        width: sW,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xff4362FF),
        ),
        child: Center(
          child: txt(
            title,
            weight: FontWeight.w600,
            size: sW * 0.04,
          ),
        ),
      ),
    );
  }
}
