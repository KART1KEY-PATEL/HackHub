import 'package:flutter/material.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';

class QrResultsPage extends StatefulWidget {
  final String message;
  const QrResultsPage(this.message, {super.key});
  @override
  State<QrResultsPage> createState() => _QrResultsPage();
}

class _QrResultsPage extends State<QrResultsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Results",
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/participantHomePage");
          },
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // if (widget.message.isNotEmpty)
            Icon(
              widget.message == "You have already had food. Come back later."
                  ? Icons.error
                  : Icons.check_circle,
              color: widget.message ==
                      "You have already had food. Come back later."
                  ? Colors.red
                  : Colors.green,
              size: 200,
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: txt(
                widget.message.isEmpty
                    ? "You are permitted to go have food"
                    : widget.message,
                isBold: true,
                size: 20,
              ),
            ),
            Center(
                child: widget.message.isEmpty
                    ? txt(
                        "Please show this to the volunteer",
                        size: 20,
                        isBold: true,
                      )
                    : null),
          ],
        ),
      ),
    );
  }
}
