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

  // This function works perfectly as long as the diet times on the settings document are correct. The role of this function is to set the meal to true and assign the volunteer's QR code to the meal.
  Future<String> giveFoodToUser(String volunteerQR) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Box userBox = await Hive.openBox<UserModel>('userBox');
    String uuid = userBox.get("currentUser")!.id;
    Map<String, dynamic> previousFoodData = await __getPreviousFoodData(uuid);
    List<DateTime> mealtimes = await __getMealTimes();
    if (mealtimes.isEmpty) {
      return "Error fetching meal times. Check your connection.";
    }
    DateTime meal1StartTime = mealtimes[0], meal1EndTime = mealtimes[1];
    DateTime meal2StartTime = mealtimes[2], meal2EndTime = mealtimes[3];
    DateTime meal3StartTime = mealtimes[4], meal3EndTime = mealtimes[5];

    String volunteerForMeal1 = previousFoodData["volunteerForMeal1"] as String;
    String volunteerForMeal2 = previousFoodData["volunteerForMeal2"] as String;
    String volunteerForMeal3 = previousFoodData["volunteerForMeal3"] as String;

    bool meal1 = previousFoodData["meal1"] as bool;
    bool meal2 = previousFoodData["meal2"] as bool;
    bool meal3 = previousFoodData["meal3"] as bool;

    DateTime currentTime = DateTime.now();

    if (currentTime.isBefore(meal1EndTime) &&
        currentTime.isAfter(meal1StartTime)) {
      if (previousFoodData["meal1"] == true) {
        // Send error message to the user that the meal has already been taken.
        return "You have already had food. Come back later.";
      }
      meal1 = true;
      volunteerForMeal1 = volunteerQR;
    } else if (currentTime.isBefore(meal2EndTime) &&
        currentTime.isAfter(meal2StartTime)) {
      if (previousFoodData["meal2"] == true) {
        // Send error message to the user that the meal has already been taken.
        return "You have already had food. Come back later.";
      }
      meal2 = true;
      volunteerForMeal2 = volunteerQR;
    } else if (currentTime.isBefore(meal3EndTime) &&
        currentTime.isAfter(meal3StartTime)) {
      if (previousFoodData["meal3"] == true) {
        // Send error message to the user that the meal has already been taken.
        return "You have already had food. Come back later.";
      }
      meal3 = true;
      volunteerForMeal3 = volunteerQR;
    } else {
      // This should never be called if the time in the settings document is correct, but I wrote it because I am paranoid.
      debugPrint("Error, possibly on the meal start and endtimings.");
      return "Error: Wrong times set for food.";
    }
    final Map<String, dynamic> dataToBeUpdated = {
      "meal1": meal1,
      "volunteerForMeal1": volunteerForMeal1,
      "meal2": meal2,
      "volunteerForMeal2": volunteerForMeal2,
      "meal3": meal3,
      "volunteerForMeal3": volunteerForMeal3,
    };
    try {
      await db.collection("food").doc(uuid).update(dataToBeUpdated);
    } catch (error) {
      debugPrint("Error updating data");
      return "Error updating data to server";
    }
    return "";
  }

  Future<List<DateTime>> __getMealTimes() async {
    List<DateTime> mealTimes = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      DocumentSnapshot snapshot =
          await db.collection('settings').doc('settings').get();
      if (snapshot.exists) {
        mealTimes.add(snapshot["diet1StartTime"].toDate());
        mealTimes.add(snapshot["diet1EndTime"].toDate());
        mealTimes.add(snapshot["diet2StartTime"].toDate());
        mealTimes.add(snapshot["diet2EndTime"].toDate());
        mealTimes.add(snapshot["diet3StartTime"].toDate());
        mealTimes.add(snapshot["diet3EndTime"].toDate());
      } else {
        debugPrint("No data found");
      }
    } catch (e) {
      debugPrint("Error fetching meal times: $e");
    }
    return mealTimes;
  }

  Future<Map<String, dynamic>> __getPreviousFoodData(String uuid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> previousFoodData = {};
    try {
      previousFoodData = await db
          .collection("food")
          .doc(uuid)
          .get()
          .then((value) => value.data() as Map<String, dynamic>)
          .onError((error, stackTrace) {
        return {};
      });
    } catch (e) {
      if (e == "storage/object-not-found") {
        debugPrint("Not a user");
      }
    }

    return previousFoodData;
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
