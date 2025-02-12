class MessageModel {
  final DateTime createdAt; // Updated from String to DateTime
  final String createdBy;
  final String link;
  final String message;
  final String photoUrl;

  MessageModel({
    required this.createdAt,
    required this.createdBy,
    required this.link,
    required this.message,
    required this.photoUrl,
  });

  /// **Convert JSON to MessageModel**
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      createdAt: json['createdAt'] != null
          ? DateTime.parse(
              json['createdAt']) // Converts timestamp string to DateTime
          : DateTime.now(), // Default value if missing
      createdBy: json['createdBy'] ?? '',
      link: json['link'] ?? '',
      message: json['message'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  /// **Convert MessageModel to JSON**
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to string
      'createdBy': createdBy,
      'link': link,
      'message': message,
      'photoUrl': photoUrl,
    };
  }
}
