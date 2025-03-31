import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/food_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';

class QrResultsPage extends StatefulWidget {
  final String userId;
  const QrResultsPage({required this.userId, super.key});
  @override
  State<QrResultsPage> createState() => _QrResultsPage();
}

class _QrResultsPage extends State<QrResultsPage> {
  FoodService _service = FoodService();
  bool isLoading = false;
  String? message;
  bool? status;
  UserModel? participant;
  @override
  void initState() {
    // TODO: implement initState
    checkFoodData();
    super.initState();
  }

  void checkFoodData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> response = await _service.giveFoodToUser(widget.userId);
    message = response['message'];
    status = response['status'] == "error" ? false : true;
    // if (status!) {
    participant = await _service.getUserByUuid(widget.userId);
    setState(() {
      isLoading = false;
    });
  }

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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // if (widget.message.isNotEmpty)
                  Icon(
                    !status! ? Icons.error : Icons.check_circle,
                    color: !status! ? Colors.red : Colors.green,
                    size: 200,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: txt(
                      message!,
                      isBold: true,
                      textAlign: TextAlign.center,
                      size: 20,
                    ),
                  ),
                  // status!
                  SizedBox(
                    height: 12,
                  ),
                  Column(
                    children: [
                      txt(
                        "Participant Team Name: ${participant!.teamId}",
                        size: 18,
                      ),
                      txt(
                        "Participant Name: ${participant!.firstName} ${participant!.lastName}",
                        size: 18,
                      )
                    ],
                  ),
                  // : SizedBox(),
                  // Center(
                  //     child: status
                  //         ? txt(
                  //             "Please show this to the volunteer",
                  //             size: 20,
                  //             isBold: true,
                  //           )
                  //         : null),
                ],
              ),
      ),
    );
  }
}
