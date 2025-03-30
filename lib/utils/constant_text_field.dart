import 'package:flutter/material.dart';
import 'package:hacknow/utils/text_util.dart';

class ContantTextField extends StatefulWidget {
  ContantTextField({
    super.key,
    required this.showTitle,
    required this.title,
    required this.defaultText,
  });
  bool showTitle;
  String title;
  String defaultText;

  @override
  State<ContantTextField> createState() => _ContantTextFieldState();
}

class _ContantTextFieldState extends State<ContantTextField> {
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    _textEditingController.text = widget.defaultText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showTitle
            ? Column(
                children: [
                  txt(
                    widget.title,
                  ),
                  SizedBox(
                    height: sH * 0.01,
                  ),
                ],
              )
            : SizedBox(),
        SizedBox(
          height: sH * 0.065,
          child: TextField(
            readOnly: true,
            controller: _textEditingController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.title,
              fillColor: const Color.fromARGB(255, 60, 63, 73),
            ),
          ),
        ),
      ],
    );
  }
}
