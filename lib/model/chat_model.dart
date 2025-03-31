import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum MessageType {
  message,
  ticket,
  announcement,
}

extension MessageTypeExtension on MessageType {
  String get name {
    switch (this) {
      case MessageType.message:
        return 'message';
      case MessageType.ticket:
        return 'ticket';
      case MessageType.announcement:
        return 'announcement';
    }
  }

  static MessageType fromString(String value) {
    switch (value) {
      case 'message':
        return MessageType.message;
      case 'ticket':
        return MessageType.ticket;
      case 'announcement':
        return MessageType.announcement;
      default:
        throw ArgumentError('Unknown MessageType: $value');
    }
  }
}

class ChatMessage {
  final String message;
  final String createdBy;
  final String? teamName;
  final String userType;
  final String? image;
  String? assignedVolunteer;
  Timestamp? timeStamp;
  String? id;
  final MessageType messageType;
  final String issueType;

  ChatMessage({
    required this.message,
    required this.createdBy,
    required this.userType,
    this.teamName,
    this.image,
    this.assignedVolunteer,
    Timestamp? timeStamp,
    this.id,
    required this.messageType,
    required this.issueType,
  }) : timeStamp = timeStamp ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'createdBy': createdBy,
      'userType': userType,
      'teamName': teamName,
      'image': image,
      'timeStamp': timeStamp,
      'messageType': messageType.name, // Convert enum to string
      'issueType': issueType,
      'assignedVolunteer': assignedVolunteer,
      'id': id ?? const Uuid().v4(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] ?? '',
      createdBy: map['createdBy'] ?? '',
      userType: map['userType'] ?? '',
      teamName: map['teamName'],
      image: map['image'],
      issueType: map['issueType'] ?? '',
      assignedVolunteer: map['assignedVolunteer'],
      timeStamp: map['timeStamp'],
      id: map['id'],
      messageType: MessageTypeExtension.fromString(
          map['messageType'] ?? 'message'), // Convert string to enum
    );
  }
}
