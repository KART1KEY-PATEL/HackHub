import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/model/chat_model.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/pages/chat_page/image_preview_page.dart';
import 'package:hacknow/services/chat_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  UserModel? currentUser;
  String? teamName;
  bool isLoading = true; // Track loading state

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

  Future<String?> _getVolunteerName(String? userId) async {
    if (userId == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.get('firstName'); // Assuming 'firstName' is the field name
      }
      return null;
    } catch (e) {
      print('Error fetching volunteer name: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: customAppBar(title: ("Chat Page"), actions: [
        if (!isLoading)
          currentUser!.userType == "participant"
              ? TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/createTicketPage');
                  },
                  child: Text(
                    "Create Ticket",
                  ),
                )
              : SizedBox(),
      ]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : currentUser == null
              ? Center(child: txt("User not found. Please restart the app."))
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<ChatMessage>>(
                        stream: _chatService.getChatMessages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: txt("Error fetching messages"));
                          }

                          final messages = snapshot.data ?? [];

                          if (messages.isEmpty) {
                            return Center(child: txt("No messages yet"));
                          }

                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final chat = messages[index];

                              // **Handle null check safely**
                              final isMe =
                                  (currentUser?.id ?? "") == chat.createdBy;

                              return (chat.messageType != MessageType.ticket)
                                  ? Align(
                                      alignment: isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.blueAccent
                                              : Colors.grey[800],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // **Display teamName if available, otherwise userType**
                                            txt(
                                              chat.teamName != null &&
                                                      chat.teamName!.isNotEmpty
                                                  ? "Team: ${chat.teamName!.toUpperCase()}"
                                                  : "${chat.userType.toUpperCase()}" ==
                                                          "VOLUNTEER"
                                                      ? "Organizing Committee"
                                                      : "${chat.userType.toUpperCase()}",
                                              size: 16,
                                              isBold: true,
                                            ),
                                            const SizedBox(height: 4),

                                            if (chat.image != null &&
                                                chat.image!.isNotEmpty)
                                              Image.network(chat.image!,
                                                  width: 200),

                                            if (chat.message.isNotEmpty)
                                              txt(
                                                chat.message,
                                                size: 16,
                                                weight: FontWeight.w500,
                                              ),

                                            txt(
                                              _formatTimestamp(chat.timeStamp!),
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Align(
                                      alignment: isMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        width: sW * 0.7,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.blueAccent
                                              : Colors.grey[800],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FractionallySizedBox(
                                              child: Container(
                                                width: sW * 0.7,
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                  color:
                                                      currentUser!.userType ==
                                                              'volunteer'
                                                          ? Colors.blueAccent
                                                          : Colors.grey[800],
                                                ),
                                                child: Row(
                                                  children: [
                                                    txt(
                                                      "Ticket - ${chat.issueType}",
                                                      size: 16,
                                                      weight: FontWeight.w700,
                                                    ),
                                                    Spacer(),
                                                    if (chat.assignedVolunteer !=
                                                            null &&
                                                        chat.assignedVolunteer ==
                                                            currentUser!.id &&
                                                        !chat.ticketClosed!)
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (!chat
                                                              .ticketClosed!) {
                                                            try {
                                                              // First get the current document to find the array index
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'chats')
                                                                  .doc('chat')
                                                                  .update({
                                                                'messages':
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  chat.toMap()
                                                                ]),
                                                              });

                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'chats')
                                                                  .doc('chat')
                                                                  .update({
                                                                'messages':
                                                                    FieldValue
                                                                        .arrayUnion([
                                                                  {
                                                                    ...chat
                                                                        .toMap(),
                                                                    'ticketClosed':
                                                                        true
                                                                  }
                                                                ]),
                                                              });
                                                            } catch (e) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Error closing ticket: $e')),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal:
                                                                sW * 0.02,
                                                            vertical:
                                                                sH * 0.007,
                                                          ),
                                                          child: txt(
                                                            chat.ticketClosed!
                                                                ? "Closed"
                                                                : "Close Ticket",
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    if (chat.ticketClosed!)
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: sW * 0.02,
                                                          vertical: sH * 0.007,
                                                        ),
                                                        child: txt(
                                                          "Closed",
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Container(
                                            //   height: sH * 0.04,
                                            //   // width: sW,
                                            //   color: Colors.amber,
                                            // ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  txt(
                                                    chat.teamName != null &&
                                                            chat.teamName!
                                                                .isNotEmpty
                                                        ? "Team: ${chat.teamName!.toUpperCase()}"
                                                        : "${chat.userType.toUpperCase()}" ==
                                                                "VOLUNTEER"
                                                            ? "Organizing Committee"
                                                            : "${chat.userType.toUpperCase()}",
                                                    size: 16,
                                                    isBold: true,
                                                  ),
                                                  const SizedBox(height: 4),

                                                  if (chat.image != null &&
                                                      chat.image!.isNotEmpty)
                                                    Container(
                                                      // color: Colors.amber,
                                                      // width: sW * 0.6,
                                                      height: sH * 0.04,
                                                      child: Row(
                                                        children: [
                                                          txt("View Image",
                                                              size: 16,
                                                              weight: FontWeight
                                                                  .w500),
                                                          Spacer(),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .remove_red_eye,
                                                              color: CustomColor
                                                                  .whiteTextColor,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Curent User Id: ${chat.createdBy != currentUser!.id}");
                                                              if (chat.createdBy ==
                                                                      currentUser!
                                                                          .id ||
                                                                  currentUser!
                                                                          .userType ==
                                                                      "volunteer") {
                                                                if (chat.image !=
                                                                    null) {
                                                                  // Assuming _imageUrl is where you store the image URL
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ImagePreviewPage(
                                                                              imageUrl: chat.image!),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text('No image available')),
                                                                  );
                                                                }
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'You cannot view other teams ticket image')),
                                                                );
                                                                return;
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  // Image.network(chat.image!,
                                                  //     width: 200),

                                                  if (chat.message.isNotEmpty)
                                                    txt(
                                                      chat.message,
                                                      size: 16,
                                                      weight: FontWeight.w500,
                                                    ),

                                                  Row(
                                                    children: [
                                                      txt(
                                                        _formatTimestamp(
                                                            chat.timeStamp!),
                                                        size: 12,
                                                      ),
                                                      Spacer(),
                                                      if (currentUser!
                                                                  .userType ==
                                                              "volunteer" ||
                                                          currentUser!.id ==
                                                              chat.createdBy)
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (chat.assignedVolunteer ==
                                                                null) {
                                                              try {
                                                                // 1. Get current chat document
                                                                final doc = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'chats')
                                                                    .doc('chat')
                                                                    .get();

                                                                // 2. Check for existing open tickets
                                                                final messages =
                                                                    doc.get('messages')
                                                                            as List<dynamic>? ??
                                                                        [];

                                                                final hasOpenTicket = messages.any(
                                                                    (message) =>
                                                                        message['id'] !=
                                                                            chat
                                                                                .id && // Different ticket
                                                                        message['assignedVolunteer'] ==
                                                                            currentUser!
                                                                                .id &&
                                                                        (message['ticketClosed'] ==
                                                                                null ||
                                                                            !message['ticketClosed']));

                                                                if (hasOpenTicket) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'You must close your current ticket first!'),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2),
                                                                    ),
                                                                  );
                                                                  return;
                                                                }

                                                                // 3. Proceed with assignment if no open tickets
                                                                final updatedMessages =
                                                                    messages.map(
                                                                        (message) {
                                                                  if (message[
                                                                          'id'] ==
                                                                      chat.id) {
                                                                    return {
                                                                      ...message,
                                                                      'assignedVolunteer':
                                                                          currentUser!
                                                                              .id,
                                                                    };
                                                                  }
                                                                  return message;
                                                                }).toList();

                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'chats')
                                                                    .doc('chat')
                                                                    .update({
                                                                  'messages':
                                                                      updatedMessages
                                                                });

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Successfully assigned to you!')),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'Error: ${e.toString()}')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: FutureBuilder<
                                                              String?>(
                                                            future: _getVolunteerName(
                                                                chat.assignedVolunteer),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                                );
                                                              }

                                                              return Container(
                                                                // width: sW * 0.25,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal: 7,
                                                                  vertical: 5,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: currentUser!
                                                                              .userType ==
                                                                          'volunteer'
                                                                      ? Colors
                                                                          .blueAccent
                                                                      : Colors.grey[
                                                                          800],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                ),
                                                                child: Center(
                                                                  child: txt(
                                                                    (chat.assignedVolunteer ==
                                                                                null &&
                                                                            currentUser!.userType ==
                                                                                "volunteer")
                                                                        ? "Assign To Yourself"
                                                                        : (chat.assignedVolunteer ==
                                                                                null)
                                                                            ? "To be Assigned"
                                                                            : "Assigned To: ${snapshot.data ?? 'Unknown'}",
                                                                    size: 12,
                                                                    weight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // **Display teamName if available, otherwise userType**
                                          ],
                                        ),
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                    _buildMessageInput(),
                  ],
                ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: Colors.grey[900],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && currentUser != null) {
      ChatMessage message = ChatMessage(
          message: _messageController.text,
          createdBy: currentUser!.id,
          userType: currentUser!.userType,
          messageType: MessageType.message,
          ticketClosed: false,
          teamName: currentUser!.userType == "participant" ? teamName : null,
          issueType: '');
      _chatService.sendMessage(
        message: message,
      );
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User data not loaded. Please try again.")),
      );
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute}";
  }
}
