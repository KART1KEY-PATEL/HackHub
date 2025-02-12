import 'dart:math';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String userType;
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String phoneNumber;
  @HiveField(4)
  final String collegeName;
  @HiveField(5)
  final bool external;
  @HiveField(6)
  final String gender;
  @HiveField(7)
  final String username;
  @HiveField(8)
  final String password;
  @HiveField(9)
  final bool approved;
  @HiveField(10)
  final String id;

  UserModel({
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.collegeName,
    required this.external,
    required this.gender,
    required this.username,
    required this.password,
    required this.approved,
    required this.id,
  });

  // Ensure `fromJson` handles missing values properly
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userType: json["userType"] ?? "participant",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      collegeName: json["collegeName"] ?? "",
      external: json["external"] ?? false,
      gender: json["gender"] ?? "Male",
      username: json["username"] ?? "Unknown",
      password: json["password"] ?? "Unknown@1234",
      approved: json['approved'] ?? false,
      id: json['id'] ?? ""
    );
  }

  static String generateUsername(String name, String phone) {
    String namePart = name.substring(0, min(4, name.length));
    String phonePart = phone.substring(max(0, phone.length - 4));
    return namePart + phonePart;
  }

  /// Generate a password (First 4 characters of name + "@" + Random 4-digit number)
  static String generatePassword(String name) {
    String namePart = name.substring(0, min(4, name.length));
    String randomDigits = (Random().nextInt(9000) + 1000).toString();
    return '$namePart@$randomDigits';
  }
}

