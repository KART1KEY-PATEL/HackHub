import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/model/chat_model.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/chat_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  String? _imageUrl; // To store the Firebase image URL
  bool isLoading = false;
  bool imageUploading = false;
  UserModel? currentUser;
  String? teamName;
  final ChatService _chatService = ChatService();

  TextEditingController _messageController = TextEditingController();
  List<String> issueType = [
    "Electrical",
    "Technical",
    "Management",
    "Food",
  ];
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      _loadUserData();
    });
  }

  /// Load user data from Hive storage
  Future<void> _loadUserData() async {
    var userBox = Hive.box<UserModel>('userBox');

    if (userBox.isNotEmpty) {
      currentUser = userBox.get("currentUser");

      if (currentUser != null) {
        print("User Type: ${currentUser!.userType}");

        if (currentUser!.userType == "participant") {
          print("Fetching team for: ${currentUser!.id}");
          await _fetchTeamName(currentUser!.id);
        }
      }
    }

    setState(() => isLoading = false); // Update state after fetching data
  }

  Future<void> _fetchTeamName(String userId) async {
    try {
      print("Fetching team name for User ID: $userId");

      // Check if the user is a Team Leader
      QuerySnapshot teamLeaderSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamLeaderId', isEqualTo: userId)
          .get();

      if (teamLeaderSnapshot.docs.isNotEmpty) {
        setState(() {
          teamName = teamLeaderSnapshot.docs.first.id;
        });
        return;
      }

      // Check if the user is a Team Member
      QuerySnapshot teamMemberSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamMembers', arrayContains: userId)
          .get();

      if (teamMemberSnapshot.docs.isNotEmpty) {
        setState(() {
          teamName = teamMemberSnapshot.docs.first.id;
        });
      }
    } catch (e) {
      print("Error fetching team name: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (imageUploading) return;
    setState(() {
      imageUploading = true;
    });
    // Request permissions based on platform
    permission.PermissionStatus status;
    if (Platform.isAndroid) {
      if (await permission.Permission.mediaLibrary.isGranted) {
        status = await permission.Permission.mediaLibrary.request();
      } else {
        status = await permission.Permission.photos.request();
      }
    } else if (Platform.isIOS) {
      status = await permission.Permission.photos.request();
    } else {
      return;
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    // Pick image from gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      // Upload to Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child(
            'tickets/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();

      setState(() {
        _imageUrl = url;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
      setState(() {
        imageUploading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      setState(() {
        imageUploading = false;
      });
    }
    setState(() {
      imageUploading = false;
    });
  }

  int selectedIssueType = -1;
  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: customAppBar(
        title: "Create Ticket Page",
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColor.whiteTextColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              txt(
                "Message",
                size: sW * 0.035,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                decoration:
                    InputDecoration(hintText: 'There is problem with...'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a message.";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: sH * 0.02,
              ),
              txt("Issue Type", size: sW * 0.035),
              const SizedBox(height: 8.0),
              SizedBox(
                height: sH * 0.04,
                width: sW,
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (selectedIssueType == index) {
                          setState(() {
                            selectedIssueType = -1;
                          });
                        }
                        setState(() {
                          selectedIssueType = index;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sW * 0.04,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: selectedIssueType != -1
                              ? index == selectedIssueType
                                  ? CustomColor.primaryButtonColor
                                  : null
                              : null,
                          border: Border.all(
                            color: CustomColor.primaryButtonColor,
                          ),
                        ),
                        child: Center(
                          child: txt(
                            issueType[index],
                            // color: selectedIssueType != -1
                            //     ? index == selectedIssueType
                            //         ? CustomColor.primaryButtonColor
                            //         : CustomColor.
                            //     : null,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      width: sW * 0.02,
                    );
                  },
                  itemCount: issueType.length,
                ),
              ),
              SizedBox(height: sH * 0.02),
              txt("Attach Photo", size: sW * 0.035),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: _uploadImage,
                child: Container(
                  width: sW,
                  height: sH * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imageUploading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : _imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Icon(Icons.add_a_photo, color: Colors.white),
                ),
              ),
              SizedBox(
                height: sH * 0.2,
              ),
              NextButton(
                onTapFunction: () async {
                  if (isLoading) return;
                  setState(() {
                    isLoading = true;
                  });
                  if (_messageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a message')),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  if (selectedIssueType == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select an issue type')),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  if (_imageUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please upload an image')),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  ChatMessage message = ChatMessage(
                    ticketClosed: false,
                    message: _messageController.text,
                    createdBy: currentUser!.id,
                    userType: currentUser!.userType,
                    messageType: MessageType.ticket,
                    teamName: currentUser!.userType == "participant"
                        ? teamName
                        : null,
                    issueType: issueType[selectedIssueType],
                    image: _imageUrl,
                  );
                  try {
                    print("sending message");
                    await _chatService.sendMessage(
                      message: message,
                    );
                  } catch (e) {
                    print("Error sending message: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                  setState(() {
                    isLoading = false;
                  });
                  _messageController.clear();
                  setState(() {
                    _imageUrl = null;
                    selectedIssueType = -1;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket submitted')),
                  );
                },
                title: isLoading ? "Processing..." : "Submit Ticket",
              )
            ],
          ),
        ),
      ),
    );
  }
}
