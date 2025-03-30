import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hacknow/model/user_model.dart';

class LoginService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Operations
  Future<void> createUser({
    required UserModel user,
  }) async {
    await _firestore.collection("users").doc(user.id).set({
      "id": user.id,
      "firstName": user.firstName,
      "lastName": user.lastName,
      "phoneNumber": user.phoneNumber,
      "collegeName": user.collegeName,
      "gender": user.gender,
      "external": user.external,
      "teamId": user.teamId,
      "userType": user.userType,
      "username": user.username,
      "password": user.password,
    });
  }

  Future<void> createFoodRecord(String userId) async {
    await _firestore.collection("food").doc(userId).set({
      "meal1": false,
      "meal2": false,
      "meal3": false,
      "meal4": false,
      "meal5": false,
      "meal6": false,
      "meal7": false,
      "meal8": false,
      "volunteerForMeal1": "",
      "volunteerForMeal2": "",
      "volunteerForMeal3": "",
      "volunteerForMeal4": "",
      "volunteerForMeal5": "",
      "volunteerForMeal6": "",
      "volunteerForMeal7": "",
      "volunteerForMeal8": "",
    });
  }

  // Team Operations
  Future<void> createOrUpdateTeam({

    required String teamName,
    required String teamLeaderId,
    required List<String> teamMembers,
    required int teamSize,
  }) async {
    final teamRef = _firestore.collection("teams").doc(teamName);
    final teamData = {
      "name": teamName,
      "teamLeaderId": teamLeaderId,
      "teamMembers": teamMembers,
      "teamSize": teamSize,
    };

    try {
      // First try to update all fields atomically
      await teamRef.update({
        "teamLeaderId": teamLeaderId,
        "teamMembers": teamMembers,
        "teamSize": teamSize,
      });
    } catch (e) {
      // If update fails (document doesn't exist), create with full data
      await teamRef.set({
        ...teamData,
        "registered": false,
      });
    }
  }

  // Add more methods as needed for other operations
  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection("users").doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection("users").doc(userId).update(data);
  }

  // Add other common queries you need...
}
