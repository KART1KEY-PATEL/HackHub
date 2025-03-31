import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hacknow/model/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String chatDocId = "chat"; 
  Stream<List<ChatMessage>> getChatMessages() {
    return _firestore
        .collection("chats")
        .doc(chatDocId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final List<dynamic> messagesData = snapshot.data()?["messages"] ?? [];
      print("Messages Data : ${messagesData}");
      List<ChatMessage> messages = messagesData
          .map((msg) => ChatMessage.fromMap(msg as Map<String, dynamic>))
          .toList();
      messages
          .sort((a, b) => b.timestamp.compareTo(a.timestamp)); //  Sort DESC
      return messages;
    });
  }

  Future<void> sendMessage(String message, String createdBy, String userType,
      {String? teamName, String? image}) async {
    final newMessage = {
      "message": message,
      "createdBy": createdBy,
      "userType": userType,
      "teamName":
          userType == "participant" ? teamName : null,
      "image": image ?? "",
      "timeStamp": Timestamp
          .now(), 
    };

    final chatRef = _firestore.collection("chats").doc(chatDocId);

    await chatRef.update({
      "messages":
          FieldValue.arrayUnion([newMessage]) // Appending message to array
    }).catchError((error) async {
      await chatRef.set({
        "messages": [newMessage] // Create the document if it doesn't exist
      });
    });
  }
}