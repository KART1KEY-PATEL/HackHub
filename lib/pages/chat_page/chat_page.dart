import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/chat_model.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/chat_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: ("Chat Page"),
      ),
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

                              return Align(
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
                                    borderRadius: BorderRadius.circular(10),
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
                                        Image.network(chat.image!, width: 200),

                                      if (chat.message.isNotEmpty)
                                        txt(
                                          chat.message,
                                          size: 16,
                                          weight: FontWeight.w500,
                                        ),

                                      txt(
                                        _formatTimestamp(chat.timestamp),
                                        size: 12,
                                      ),
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
      _chatService.sendMessage(
        _messageController.text,
        currentUser!.id,
        currentUser!.userType,
        teamName: currentUser!.userType == "participant" ? teamName : null,
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
