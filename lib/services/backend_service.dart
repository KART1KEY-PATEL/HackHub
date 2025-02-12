import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:hacknow/model/user_model.dart';

import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class Backendservice {
// Load JSON credentials
  Future<GSheets> loadGoogleSheets() async {
    String jsonCredentials =
        await rootBundle.loadString('assets/credentials.json');
    final credentials = jsonDecode(jsonCredentials);
    return GSheets(credentials);
  }

  Future<List<String>> fetchTeamMembers(String teamName) async {
    final gsheets = await loadGoogleSheets();
    final spreadsheetId =
        "12Sg_pWzVrDoz-icj9cMQrmLcj6rd-J8ALUQRSfx6rFg"; // Replace with actual ID
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    // Get the worksheet containing team data
    final worksheet =
        spreadsheet.worksheetByTitle('Teams'); // Change sheet name accordingly

    if (worksheet == null) {
      print("Worksheet not found");
      return [];
    }

    // Fetch all rows
    final rows = await worksheet.values.allRows();

    if (rows == null || rows.isEmpty) {
      print("No data found in the sheet");
      return [];
    }

    List<String> teamMembers = [];

    // Find the rows where Team Name matches and extract Participant Name
    for (var row in rows) {
      if (row.length > 3 && row[2] == teamName) {
        teamMembers.add(row[4]); // Column E (Participant Name)
      }
    }

    return teamMembers;
  }

  // This function works perfectly as long as the diet times on the settings document are correct. The role of this function is to set the meal to true and assign the volunteer's QR code to the meal.
  Future<String> giveFoodToUser(String volunteerQR) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Box userBox = await Hive.openBox<UserModel>('userBox');
    String uuid  = userBox.get("currentUser")!.id;
    Map<String, dynamic> previousFoodData = await __getPreviousFoodData(uuid);
    List<DateTime> mealtimes = await __getMealTimes();
    if(mealtimes.isEmpty){
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
}
