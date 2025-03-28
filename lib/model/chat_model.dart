import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String message;
  final String createdBy;
  final String? teamName;
  final String userType;
  final String? image;
  final Timestamp timestamp;

  ChatMessage({
    required this.message,
    required this.createdBy,
    required this.userType,
    this.teamName,
    this.image,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'createdBy': createdBy,
      'userType': userType,
      'teamName': teamName,
      'image': image,
      'timeStamp': timestamp,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'],
      createdBy: map['createdBy'],
      userType: map['userType'],
      teamName: map['teamName'],
      image: map['image'],
      timestamp: map['timeStamp'],
    );
  }
}
