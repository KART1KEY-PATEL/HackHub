import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class Backendservice {
// Load JSON credentials
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GSheets> loadGoogleSheets() async {
    String jsonCredentials =
        await rootBundle.loadString('assets/credentials.json');
    final credentials = jsonDecode(jsonCredentials);
    return GSheets(credentials);
  }

  Future<Map<String, String>> fetchTeamMembers(String teamName) async {
    final gsheets = await loadGoogleSheets();
    final spreadsheetId =
        "12Sg_pWzVrDoz-icj9cMQrmLcj6rd-J8ALUQRSfx6rFg"; // Replace with actual ID
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    // Get the worksheet containing team data
    final worksheet =
        spreadsheet.worksheetByTitle('Sheet1'); // Change sheet name accordingly

    if (worksheet == null) {
      print("Worksheet not found");
      return {};
    }

    // Fetch all rows
    final rows = await worksheet.values.allRows();

    if (rows == null || rows.isEmpty) {
      print("No data found in the sheet");
      return {};
    }

    Map<String, String> teamMembers = {};

    // Find the rows where Team Name matches and extract Participant Name & Email
    for (var row in rows) {
      if (row.length > 5 && row[2].toUpperCase() == teamName) {
        String participantName = row[4]; // Column E (Participant Name)
        String participantEmail = row[5]; // Column F (Participant Email)
        teamMembers[participantName] = participantEmail;
      }
    }

    return teamMembers;
  }

  Future<void> updateIOSUserStatus(String email, bool status) async {
    final gsheets = await loadGoogleSheets();
    final spreadsheetId = "12Sg_pWzVrDoz-icj9cMQrmLcj6rd-J8ALUQRSfx6rFg";
    final worksheet =
        (await gsheets.spreadsheet(spreadsheetId)).worksheetByTitle('Sheet1');

    if (worksheet == null) {
      print("Worksheet not found");
      return;
    }

    final rows = await worksheet.values.allRows();

    for (int i = 0; i < rows.length; i++) {
      if (rows[i][5] == email) {
        // Assuming email is in Column F
        await worksheet.values.insertValue(
          status ? "TRUE" : "FALSE",
          column: 12,
          row: i + 1,
        );
        print("Updated IOS Users status for $email: $status");
        break;
      }
    }
  }

  Future<void> updateAttendance(String email, String status) async {
    final gsheets = await loadGoogleSheets();
    final spreadsheetId = "12Sg_pWzVrDoz-icj9cMQrmLcj6rd-J8ALUQRSfx6rFg";
    final worksheet =
        (await gsheets.spreadsheet(spreadsheetId)).worksheetByTitle('Sheet1');

    if (worksheet == null) {
      print("Worksheet not found");
      return;
    }

    final rows = await worksheet.values.allRows();

    for (int i = 0; i < rows.length; i++) {
      if (rows[i][5] == email) {
        // Email Column F
        await worksheet.values.insertValue(
          status,
          column: 13, // Assuming "Attendance" is Column I
          row: i + 1,
        );
        print("Updated Attendance status for $email: $status");
        break;
      }
    }
  }


  Future<void> deleteDuplicateUsers() async {
    try {
      CollectionReference usersRef = _firestore.collection('users');
      CollectionReference foodRef = _firestore.collection('food');
      CollectionReference teamsRef = _firestore.collection('teams');

      // Fetch all users
      QuerySnapshot usersSnapshot = await usersRef.get();

      // Store usernames and their corresponding document IDs
      Map<String, String> userMap = {};
      List<String> duplicateDocIds = [];

      for (QueryDocumentSnapshot doc in usersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String username = data['username'];
        String docId = doc.id;

        if (userMap.containsKey(username)) {
          // If the username already exists, mark this document as duplicate
          duplicateDocIds.add(docId);
        } else {
          userMap[username] = docId;
        }
      }

      // Now delete duplicates from users, food, and teams
      for (String docId in duplicateDocIds) {
        // Delete from users
        await usersRef.doc(docId).delete();
        print("Deleted user: $docId");

        // Delete from food collection
        await foodRef.doc(docId).delete();
        print("Deleted food entry for: $docId");

        // Remove user from all teams
        QuerySnapshot teamsSnapshot = await teamsRef.get();
        for (QueryDocumentSnapshot teamDoc in teamsSnapshot.docs) {
          List<dynamic> teamMembers = teamDoc['teamMembers'];
          if (teamMembers.contains(docId)) {
            // Remove user from the team
            teamMembers.remove(docId);
            await teamsRef.doc(teamDoc.id).update({'teamMembers': teamMembers});
            print("Removed $docId from team: ${teamDoc.id}");
          }
        }
      }

      print("Duplicate user cleanup completed successfully!");
    } catch (e) {
      print("Error deleting duplicate users: $e");
    }
  }

  Future<void> backupFoodToFirestore() async {
    try {
      // Reference to the original and backup collections
      CollectionReference usersRef = _firestore.collection('food');
      CollectionReference backupRef = _firestore.collection('food_backup');

      // Fetch all users
      QuerySnapshot usersSnapshot = await usersRef.get();

      // Copy each document to users_backup
      for (QueryDocumentSnapshot doc in usersSnapshot.docs) {
        await backupRef.doc(doc.id).set(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error backing up users: $e");
      throw e;
    }
  }

  Future<void> backupTeamsToFirestore() async {
    try {
      // Reference to the original and backup collections
      CollectionReference usersRef = _firestore.collection('teams');
      CollectionReference backupRef = _firestore.collection('teams_backup');

      // Fetch all users
      QuerySnapshot usersSnapshot = await usersRef.get();

      // Copy each document to users_backup
      for (QueryDocumentSnapshot doc in usersSnapshot.docs) {
        await backupRef.doc(doc.id).set(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error backing up users: $e");
      throw e;
    }
  }

  Future<void> backupUsersToFirestore() async {
    try {
      // Reference to the original and backup collections
      CollectionReference usersRef = _firestore.collection('users');
      CollectionReference backupRef = _firestore.collection('users_backup');

      // Fetch all users
      QuerySnapshot usersSnapshot = await usersRef.get();

      // Copy each document to users_backup
      for (QueryDocumentSnapshot doc in usersSnapshot.docs) {
        await backupRef.doc(doc.id).set(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error backing up users: $e");
      throw e;
    }
  }

  // TODO: Call this function during the registration of the user to set the initial values of the food document.
  Future<void> setInitialValues(String uuid) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      db.collection("food").doc(uuid).set({
        "meal1": false,
        "volunteerForMeal1": "",
        "meal2": false,
        "volunteerForMeal2": "",
        "meal3": false,
        "volunteerForMeal3": "",
      });
    } catch (e) {
      debugPrint("Error setting initial values");
    }
    return Future<void>.value();
  }

  // Load JSON credentials and return GSheets instance
  Future<GSheets> _loadGoogleSheets() async {
    String jsonCredentials =
        await rootBundle.loadString('assets/credentials.json');
    final credentials = jsonDecode(jsonCredentials);
    return GSheets(credentials);
  }

  // Fetch unique team names from Google Sheets
  Future<Set<String>> fetchUniqueTeamNames() async {
    final gsheets = await _loadGoogleSheets();
    final spreadsheetId =
        "12Sg_pWzVrDoz-icj9cMQrmLcj6rd-J8ALUQRSfx6rFg"; // Your Sheet ID
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
    final worksheet =
        spreadsheet.worksheetByTitle('Sheet1'); // Update Sheet Name

    if (worksheet == null) {
      print("Worksheet not found");
      return {};
    }

    final rows = await worksheet.values.allRows();
    if (rows == null || rows.isEmpty) {
      print("No data found in the sheet");
      return {};
    }

    Set<String> teamNames = {};

    // Extract team names (Assuming "Team Name" is in Column C)
    for (var row in rows) {
      if (row.length > 2 && row[2].isNotEmpty) {
        teamNames.add(row[2].trim().toUpperCase());
      }
    }

    return teamNames;
  }

  // Add new teams to Firestore
  Future<void> updateTeamsInFirestore() async {
    Set<String> teamNames = await fetchUniqueTeamNames();

    for (String teamName in teamNames) {
      DocumentReference teamDocRef =
          _firestore.collection("teams").doc(teamName);

      DocumentSnapshot teamDoc = await teamDocRef.get();
      if (!teamDoc.exists) {
        // Add team if it doesn't exist
        await teamDocRef.set({
          "registered": false,
          "teamLeaderId": "",
          "teamMembers": [],
          "teamSize": 0,
        });
        print("Added team: $teamName");
      } else {
        print("Team $teamName already exists, skipping...");
      }
    }
  }
}
